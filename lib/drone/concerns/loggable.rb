module Drone::Concerns::Loggable

  def self.included(base)
    base.extend(ClassMethods)
  end

  def logger(*args)
    self.class.logger(*args)
  end

  module ClassMethods

    def logger(*args)
      Drone.logger(*args)
    end

  end
end