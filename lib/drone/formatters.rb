module Drone::Formatter

  module HTML
    def self.call(object, _env)
      params = {
        drone_status: Drone::Status.new
      }

      case object
      when Drone::Targets
        Drone::Erb::Collection.new(params.merge({ records: object })).render
      when Drone::Target
        Drone::Erb::Model.new(params.merge({ record: object })).render
      when Symbol
        Drone::Erb::Page.new(params.merge({ page: object })).render
      else
        ''#raise "Can't render #{object.class.to_s} objects"
      end
    end
  end

  module PNG
    def self.call(object, _env)
      File.binread(object.is_a?(String) ? object : object.to_png)        
    end
  end

  module PDF
    def self.call(object, _env)
      File.binread(object.is_a?(String) ? object : object.to_pdf)
    end
  end

  module CSS
    def self.call(object, _env)
      File.read(object.is_a?(String) ? object : object.to_css)
    end
  end

end