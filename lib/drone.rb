require 'pathname'
require 'cgi'
require 'pp'
require 'uri'
require 'redis'
require 'digest'
require 'fileutils'
require 'logger'
require 'active_support/core_ext/hash/indifferent_access'

module Drone
  class DroneError < StandardError; end
  class RecordInvalid < DroneError; end
  class RecordNotFound < DroneError; end
  class RecipeNotFound < DroneError; end
  class ConfigurationInvalid < DroneError; end
  class CredentialInvalid < DroneError; end

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

  # Base configuration and default values
  def self.config
    @config ||= {
      phantomjs_path: File.join(Drone::ROOT, 'bin', 'phantomjs'),
      imagemagick_convert_path: File.join(Drone::ROOT, 'bin', 'convert'),
      imagemagick_identify_path: File.join(Drone::ROOT, 'bin', 'identify'),
      credentials: {},
      loaded: false,
      params: {}
    }.with_indifferent_access
  end

  def self.sync_credentials
    self.config[:credentials].each do |id, attributes|
      Drone::Credential.from_id(id, attributes.symbolize_keys).save
    end

    Drone::Credential.all
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
require './lib/drone/credential'
require './lib/drone/target'
require './lib/drone/console'
require './lib/drone/erb'
require './lib/drone/capture'
require './lib/drone/status'
require './lib/drone/formatters'
