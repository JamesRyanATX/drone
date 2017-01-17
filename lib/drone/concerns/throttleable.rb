module Drone::Concerns::Throttleable

  def self.included(base)
    base.extend(ClassMethods)
  end

  def throttle(window, &block)
    self.class.throttle(window, &block)
  end

  module ClassMethods

    def throttle(min_interval, &block)
      start_time = Time.now

      yield

      end_time = Time.now
      duration = end_time.to_i - start_time.to_i

      if duration < min_interval
        throttle = min_interval - duration

        if throttle > 0
          logger.debug("throttling by #{throttle}s")
          sleep(throttle)
        end
      end
    end

  end
end