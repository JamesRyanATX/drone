class Drone::Status

  def self.all
    self.new.all
  end

  def initialize
  end

  def all
    %w( 
      capture_count
      capture_average
      capture_rate
      error_count
      error_rate
      target_count
    ).inject({}) do |memo, metric|
      memo[metric.to_sym] = self.send(metric.to_sym)
      memo
    end
  end

  def log_capture(duration)
    redis.incr(redis_key(:capture_count))
    redis.set(redis_key(:capture_duration), capture_duration + duration.to_f.round(4))
  end

  def log_error
    redis.incr(redis_key(:error_count))
  end

  def error_count
    redis.get(redis_key(:error_count)).to_i
  end

  def error_rate
    with_precision(error_count.to_f / capture_count.to_f)
  end

  def capture_duration
    redis.get(redis_key(:capture_duration)).to_f
  end

  def capture_count
    redis.get(redis_key(:capture_count)).to_i
  end

  def capture_average
    with_precision(redis.get(redis_key(:capture_duration)).to_f / redis.get(redis_key(:capture_count)).to_f)
  end

  def capture_rate
    with_precision(1.0 / capture_average)
  end

  def target_count
    Drone::Target.count
  end

  def reset
    redis.del(redis_key(:error_count))
    redis.del(redis_key(:capture_count))
    redis.del(redis_key(:capture_duration))

    true
  end

  private

  def with_introspection(value, coercer)
    if value.nan? || value.infinite?
      0
    else
      value
    end.send(coercer.to_sym)
  end

  def with_precision(value)
    with_introspection(value, :to_f).round(2)
  end

  def redis
    Drone.redis
  end

  def redis_key(key)
    "#{Drone.config[:record_prefix]}#{key}"
  end

end