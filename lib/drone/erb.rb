require 'erb'

module Drone::Erb

  class Base

    attr_accessor :drone_status

    def initialize(locals)
      locals.each { |k, v| self.send("#{k}=", v) }
    end

    def render
      render_file(self.header) + render_file(self.template) + render_file(self.footer)
    end

    def header
      'erb/layout/header.html.erb'
    end

    def footer
      'erb/layout/footer.html.erb'
    end

    def app_url(path)
      if Drone.config[:prefix]
        "/#{Drone.config[:prefix]}#{path}"
      else
        path
      end
    end

    private

    def render_file(file)
      ERB.new(File.read(file)).result(binding)
    end

    def template_from_model(model, template_name)
      File.join('erb', "#{model.to_s.downcase.split('::').pop}s", "#{template_name}.html.erb")
    end
  end

  class Model < Drone::Erb::Base
    attr_accessor :record

    def template
      template_from_model(self.record.class, 'show')
    end
  end

  class Collection < Drone::Erb::Base
    attr_accessor :records

    def template
      template_from_model(self.records.model, 'index')
    end
  end

  class Page < Drone::Erb::Base
    attr_accessor :page

    def template
      File.join('erb', 'pages', "#{page}.html.erb")
    end
  end

end