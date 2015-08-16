require "grape"

require 'drone/concerns/loggable'

class Drone::API < Grape::API
  include Drone::Concerns::Loggable

  rescue_from Drone::RecipeNotFound do |e|
    error!({ message: "recipe not found" }, '404')
  end

  content_type :png, 'image/png'
  content_type :pdf, 'application/pdf'
  content_type :json, 'application/json'
  content_type :html, 'text/html'
  content_type :css, 'text/css'

  formatter :html, Drone::Formatter::HTML
  formatter :png, Drone::Formatter::PNG
  formatter :pdf, Drone::Formatter::PDF
  formatter :css, Drone::Formatter::CSS

  default_format :json

  helpers do

    def target_from_params
      params[:id] ? target_from_id(params[:id]) : target_from_url(params[:url])
    end

    def target_from_url(url)
      Drone::Target.from_url(url)
    end

    def target_from_id(id)
      Drone::Target.from_id(id)
    end

    def allowable_create_target_attributes
      allowable_update_target_attributes + [ 'id' ]
    end

    def allowable_update_target_attributes
      %w( capture_ready_method url )
    end

  end

  # Root redirect and various HTML pages
  get('/') { redirect '/targets.html' }
  get('/settings.html') { :settings }
  get('/documentation.html') { :documentation }
  get('/console.html') { :console }

  # GET /status
  resource :status do
    get do
      {
        targets: Drone::Target.count,
        pending: Drone::Target.queue_size(:pending),
        processing: Drone::Target.queue_size(:processing),
        completed: Drone::Target.queue_size(:completed),
        error: Drone::Target.queue_size(:error)
      }
    end
  end

  # GET /capture.[pdf|png]?url=...
  resource :capture do
    get do
      request_params = params.clone

      target = Drone::Target.from_url(request_params['url']).transient
      recipe = Drone::Recipe.from_params(request_params).to_hash

      result = target.capture_custom_recipe(recipe, {
        ready: recipe[:ready]
      })

      if params[:format] == 'json'
        {
          identifier: target.id,
          params: request_params,
          recipe: {
            name: result[:recipe_name]
          },
          url: "/targets/#{target.id}.#{request_params[:output_format]}?recipe=#{result[:recipe_name]}",
        }
      else
        result[:path]
      end
    end
  end

  # GET targets.[json|html]
  # POST /targets
  # DELETE /targets
  # GET /targets/:target_id
  resource :targets do

    get do
      Drone::Target.all
    end

    delete do
      { result: !!Drone::Target.reset({ queues: %w( pending completed processing error ) }) }
    end

    post do
      target = target_from_params

      allowable_create_target_attributes.each do |attribute|
        unless params[attribute.to_sym].nil?
          target.attributes[attribute.to_sym] = params[attribute.to_sym]
        end
      end

      target.save
    end

    # GET /targets/:target_id.json
    # GET /targets/:target_id.png
    # GET /targets/:target_id.pdf
    get ':id' do
      target = target_from_params

      unless params[:recipe].nil?
        target.prepare_recipe(params[:format], params[:recipe])
      end

      target
    end

    # PUT /targets/:target_id.json
    put ':id' do
      target = target_from_params

      allowable_update_target_attributes.each do |attribute|
        target.attributes[attribute] = params[attribute] unless attribute.nil?
      end 

      target
    end

    # DELETE /targets/:target_id.json
    delete ':id' do
      { result: !!target_from_id(params[:id]).delete }
    end

  end
end
