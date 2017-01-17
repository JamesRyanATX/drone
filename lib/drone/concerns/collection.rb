require 'drone/concerns/loggable'

module Drone::Concerns::Collection

  def self.included(base)
    base.extend(ClassMethods)

    base.include(Drone::Concerns::Loggable)

    attr_accessor :records
  end

  def initialize(records = [])
    self.records = records
  end

  def model
    self.class.config[:model]
  end

  def each(&block)
    self.records.each(&block)
  end

  def length
    self.records.length
  end

  def to_array
    self.records
  end

  def as_json
    to_array.map { |t| t.as_json }
  end

  def to_json
    as_json.to_json
  end

  module ClassMethods

    def config
      @config ||= {
        model: nil
      }
    end

    def model(model_class)
      self.config[:model] = model_class
    end

  end
end