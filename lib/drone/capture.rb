require 'drone/concerns/loggable'

Thread.class_eval do
  alias_method :initialize_without_exception_bubbling, :initialize
  def initialize(*args, &block)
    initialize_without_exception_bubbling(*args) {
      begin
        block.call
      rescue Exception => e
        Thread.main.raise e
      end
    }
  end
end

class Drone::Capture
  include Drone::Concerns::Loggable

  attr_accessor :thread_id, :options

  def initialize(thread_id, options = {})
    @thread_id = thread_id
    @options = options

    log(:debug, "initialized with #{options.inspect}")

    if continue?
      self.run
    else
      log(:debug, "nothing to do :-(")
    end
  end

  def run
    while self.continue?
      target = Drone::Target.queue_pop(:pending)

      target.capture({
        recipes: self.options[:recipes],
        thread_id: self.thread_id
      }) unless target.nil?
    end

    log(:debug, "finished")
  end

  def continue?
    Drone::Target.queue_size(:pending) > 0
  end

  def log(severity, message)
    logger.send(severity, "[T#{@thread_id}] #{message}")
  end

  private

  def self.threads
    @threads ||= []
  end

  def self.summary
    {
      source_size: Drone::Target.count,
      pending_size: Drone::Target.queue_size(:pending),
      processing_size: Drone::Target.queue_size(:processing),
      completed_size: Drone::Target.queue_size(:completed),
      threads: {
        total: self.threads.length,
        alive: self.threads.select { |t| t.alive? }.length,
        dead: self.threads.select { |t| !t.alive? }.length
      }
    }
  end

  def self.initialize_threads(options)
    logger.debug("creating #{options[:thread_count]} capture thread(s)")

    options[:thread_count].times do |thread_id|
      self.threads << Thread.new { self.new(thread_id, options) }
    end
  end

  def self.run(options = {})
    options = {
      continuous: true,
      min_capture_interval: Drone.config[:min_capture_interval],
      poll_interval: 1,
      recipes: [],
      thread_count: Drone.config[:thread_count] || 1,
      runs: 0
    }.merge(options)

    raise ArgumentError, "no recipes specified" if options[:recipes].length == 0
    
    # Ensure useless threads will not spin up
    if Drone::Target.count < options[:thread_count]
      options[:thread_count] = Drone::Target.count
    end

    while options[:continuous] || options[:runs] == 0 do
      Drone::Target.throttle(options[:min_capture_interval]) do
        Drone::Target.queue_clone(:pending)

        if options[:thread_count].nil?
          self.run_sync(options)
        else
          self.run_async(options)
        end

        logger.debug("queue summary: #{self.summary}")
      end

      options[:runs] += 1
    end
  end

  def self.run_sync(options)
    self.new(0, options)
  end

  def self.run_async(options)
    self.initialize_threads(options)

    sleep(options[:poll_interval]) while self.alive?
  end

  # Whether or not one or more capture threads are still alive
  def self.alive?
    (threads.map { |t| t.alive? ? true : nil }.compact.length > 0)
  end

end