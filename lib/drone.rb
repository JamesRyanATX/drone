require 'pathname'
require 'cgi'
require 'pp'
require 'uri'
require 'redis'
require 'digest'
require 'fileutils'
require 'logger'

module Drone
  class DroneError < StandardError; end
  class RecordInvalid < DroneError; end
  class RecordNotFound < DroneError; end
  class RecipeNotFound < DroneError; end
  class ConfigurationInvalid < DroneError; end

  module Concerns; end

  # Commonly used viewports
  DEFAULT_VIEWPORTS = {
    small:         { width:  500, height: 950 },
    large:         { width: 1140, height: 950 },
    pdf_portrait:  { width: 1140, height: 950 },
    pdf_landscape: { width: 1140, height: 950 }
  }

  # Store app root path
  ROOT = File.expand_path('../../', __FILE__)

  def self.env
    self.config[:environment]
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new
  end

  def self.logger
    if @logger.nil?
      @logger = Logger.new(self.config[:log_device])
      @logger.level = Drone.config[:log_level]
      @logger.formatter = proc do |severity, datetime, progname, msg|
         "[#{severity}] #{msg}\n"
      end
    end

    @logger
  end

  def self.redis
    @redis ||= Redis.new
  end

  # Construct a key for use in Redis.
  def self.redis_key(key)
    "#{self.config[:redis_key_prefix]}#{key}"
  end

end

$LOAD_PATH << File.join(Drone::ROOT, 'lib')

require './lib/drone/phantom'
require './lib/drone/recipe'
require './lib/drone/target'
require './lib/drone/console'
require './lib/drone/erb'
require './lib/drone/capture'
require './lib/drone/status'

require './lib/drone/formatters'
require './lib/drone/cli'
require './lib/drone/api'

