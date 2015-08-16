require 'drone/concerns/collection'
require 'drone/concerns/model'

class Drone::Targets
  include Drone::Concerns::Collection
end

class Drone::Target
  include Drone::Concerns::Model

  attr_accessor :recipe, :captured

  record_prefix 'target'

  digest :url

  queueable queues: [ :pending, :completed, :processing, :error ]

  attributes do |record|
    {
      capture_count: 0,
      capture_ready_method: 'success',
      created_at: nil,
      id: nil,
      last_capture_at: nil,
      message: nil,
      target_status: 'new',
      url: nil
    }
  end

  validate do |record|
    raise Drone::RecordInvalid, "URL required." if record.url.to_s.empty?
    raise Drone::RecordInvalid, "'#{record.url}' is not a URL." unless record.url.match(Drone.config[:url_validation_regex])
  end

  load do |record|
    record.attributes[:capture_count] = record.attributes[:capture_count].to_i
    record.attributes[:last_captured_at] = nil if record.attributes[:last_captured_at].to_s.empty?
    record.attributes[:message] = nil if record.attributes[:message].to_s.empty?
  end

  def capture_custom_recipe(recipe = {}, options = {})
    result = true
    path = nil
    name = nil

    name = Digest::MD5.hexdigest(Time.now.to_f.to_s)[0, 8]
    options.merge!({recipes: [ recipe.merge({ name: name }) ] })
  
    if Drone::Phantom.new(self, capture_filename, options).capture
      path = "#{capture_filename}.#{name}.#{recipe[:output][:format]}"
    else
      result = false
    end

    {
      result: result,
      path: path,
      recipe_name: name
    }
  end

  def capture(options = {})
    options = {
      recipes: []
    }.merge(options)

    if Drone::Phantom.new(self, capture_filename, options).capture
      self.to_queue(:completed, :processing)

      self.attributes.merge!({
        capture_count: attributes[:capture_count] + 1,
        last_capture_at: Time.now,
        target_status: 'ok',
        message: nil
      })

      true
    else
      self.to_queue(:error, :processing)

      self.attributes.merge!({
        message: 'Unknown error',
        target_status: 'error'
      })

      false
    end
  end

  def capture_url
    expanded_url = self.url.clone

    Drone.config[:params].each do |name, value|
      expanded_url.gsub!("${#{name}}", value.is_a?(Proc) ? value.call(self) : value)
    end

    expanded_url
  end

  def to_pdf(capture_recipe = nil)
    to_captured(:pdf, capture_recipe)
  end

  def to_png(capture_recipe = nil)
    to_captured(:png, capture_recipe)
  end

  def to_captured(format, capture_recipe = nil)
    capture_recipe = capture_recipe || @recipe

    raise ArgumentError, "recipe required" if capture_recipe.nil?

    captured_exists?(format, capture_recipe) ? captured_path(format, capture_recipe) : nil
  end

  def captured_exists?(format, capture_recipe)
    File.exist?(captured_path(format, capture_recipe))
  end

  def error?
    self.target_status == 'error'
  end

  def prepare_recipe(format, capture_recipe)    
    @recipe ||= capture_recipe

    unless captured_exists?(format, @recipe)
      raise Drone::RecipeNotFound, "recipe '#{@recipe}' with format '#{format}' not found"
    end
  end

  def captured_path(format, recipe)
    "#{capture_filename}.#{recipe}.#{format}"
  end

  private

  def capture_filename(options = {})
    options = {
      autocreate: true
    }.merge(options)

    timestamp = Time.now

    directory = File.join(Drone.config[:capture_path], self.id[0], self.id)
    filename = File.join(directory, self.id)

    unless Dir.exists?(directory)
      if !options[:autocreate]
        raise Drone::ConfigurationInvalid, "Capture path '#{directory}' is missing or not a directory."
      else
        FileUtils.mkdir_p(directory)
      end
    end

    filename
  end

  class << self

    def from_url(url, attrs = {})
      self.from_attribute(:url, url, attrs)
    end

  end

end

Drone::Targets.class_eval do
  model Drone::Target
end

Drone::Target.class_eval do
  collection Drone::Targets
end