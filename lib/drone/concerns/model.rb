require 'drone/concerns/loggable'
require 'drone/concerns/queueable'
require 'drone/concerns/throttleable'


module Drone::Concerns::Model

  PROTECTED_ATTRIBUTES = [ :id ]

  def self.included(base)
    base.extend(ClassMethods)

    base.include(Drone::Concerns::Loggable)
    base.include(Drone::Concerns::Queueable)
    base.include(Drone::Concerns::Throttleable)

    attr_accessor :attributes
  end

  def initialize(*args)
    initialize_attributes(args[0] || {})
  end

  def update_attributes(attrs = {})
    self.attributes.merge!(attrs)
    self
  end

  # Record should not be saved
  def transient
    @transient ||= true
    self
  end

  # Generate a unique hash for a record via config[:digest]
  def digest
    @digest ||= Digest::MD5.hexdigest(self.attributes[self.class.config[:digest]])[0, 8]
  end

  # Look for an existing ID or create a new one based on the digest attribute(s)
  def id
    attributes[:id] || digest
  end

  def record_id
    Drone.redis_key("#{self.class.config[:record_prefix]}:#{self.id}")
  end

  def load
    redis.hkeys(self.record_id).each do |attribute|
      self.attributes[attribute.to_sym] = redis.hmget(self.record_id, attribute).first
    end

    self.class.config[:load].call(self)

    self
  end

  def delete
    redis.del(self.record_id)
    redis.srem(self.class.collection_name, self.id)
    true
  end

  def save
    self if validate && persist
  end

  def redis
    self.class.redis
  end

  def persist
    self.attributes[:updated_at] = Time.now
    
    self.attributes.merge!({
      id: self.id,
      created_at: Time.now
    }) unless self.persisted?

    redis.mapped_hmset(self.record_id, self.attributes)
    redis.sadd(self.class.collection_name, self.id)

    true
  end

  def persisted?
    !self.attributes[:created_at].nil?
  end

  def validate
    self.class.config[:validate].call(self)

    true
  end

  def model
    self.class
  end

  def as_json
    self.attributes
  end

  def to_json
    as_json.to_json
  end


  protected

  def initialize_attributes(attributes)
    @attributes = self.class.config[:attributes].call(self).merge(attributes).tap do |attributes|
      attributes.each { |k, v| self.initialize_attribute(k) unless PROTECTED_ATTRIBUTES.member?(k.to_sym) }
    end
  end

  def initialize_attribute(attribute)
    self.define_singleton_method(:"#{attribute}=") { |v| @attributes[attribute.to_sym] = v }
    self.define_singleton_method(:"#{attribute}") { @attributes[attribute.to_sym] }
  end

  module ClassMethods

    def config
      @config ||= {
        attributes: Proc.new { |r| {} },
        collection: nil,
        digest: nil,
        record_prefix: 'foo',
        load: Proc.new { |r| true },
        validate: Proc.new { |r| true }
      }
    end

    def collection(collection_class)
      self.config[:collection] = collection_class
    end

    def reset(options = {})
      logger.debug("deleting #{self} records")
      redis.del(collection_name)
    end

    def digest(attribute)
      self.config[:digest] = attribute.to_sym
    end

    def record_prefix(prefix)
      self.config[:record_prefix] = prefix
    end

    def validate(&block)
      self.config[:validate] = block
    end

    def load(&block)
      self.config[:load] = block
    end

    def attributes(&block)
      self.config[:attributes] = block
    end

    def from_attribute(attribute, value, attrs = {})
      self.new({ attribute => value }).load.update_attributes(attrs)
    end

    def from_id(id)
      from_attribute(:id, id)
    end

    def all
      self.config[:collection].new(redis.smembers(self.collection_name).map { |id| from_id(id) })
    end

    def count
      redis.scard(self.collection_name)
    end

    def redis
      Drone.redis
    end

    def collection_name
      Drone.redis_key("#{self.config[:record_prefix]}s")
    end

  end

end