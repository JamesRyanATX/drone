module Drone::Concerns::Queueable

  def self.included(base)
    base.extend(ClassMethods)
  end

  def to_queue(to_queue_suffix, from_queue_suffix = nil)
    redis.srem(queue_name(from_queue_suffix), self.id) unless from_queue_suffix.nil?
    redis.sadd(queue_name(to_queue_suffix), self.id)

    self
  end

  def queue_name(queue_suffix)
    self.class.queue_name(queue_suffix)
  end

  def queue_size(queue_suffix)
    self.class.queue_size(queue_suffix)
  end

  module ClassMethods

    attr_accessor :queueable_options

    def queueable(options = {})
      @queueable_options = { queues: [] }.merge(options)
    end

    def reset(options = {})
      options = {
        queues: (self.queueable_options || {})[:queues] || []
      }.merge(options)

      options[:queues].each do |queue|
        logger.debug("reseting #{self} queue #{queue_name(queue)}")
        redis.del queue_name(queue)
      end

      super(options)
    end

    def queue_name(queue_suffix)
      Drone.redis_key("#{self.config[:record_prefix]}-#{queue_suffix}")
    end

    def queue_pop(queue_suffix)
      record_id = redis.spop(self.queue_name(queue_suffix))
      
      if record_id.nil?
        nil
      else
        self.from_id(record_id).to_queue(:processing)
      end
    end

    def queue_size(queue_suffix)
      redis.scard(self.queue_name(queue_suffix))
    end

    def queue_clone(destination_queue_suffix, source_queue_suffix = nil)
      logger.debug("cloning into queue '#{destination_queue_suffix}'")

      redis.sunionstore(queue_name(destination_queue_suffix),
        source_queue_suffix.nil? ? self.collection_name : queue_name(source_queue_suffix))
    end

  end

end