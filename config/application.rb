# This needs to stay at the top
$stdout.sync = true
$stderr.sync = true

require 'yaml'
require 'fileutils'
require 'pry'
require File.expand_path('../../lib/drone.rb', __FILE__)

Drone.config[:environment] = ENV['RAILS_ENV'] || ENV['DRONE_ENV'] || 'development'

# Pull in base app config
Drone.config.merge!(
  YAML.load(ERB.new(File.open(File.join(Drone::ROOT, 'config', 'application.yml')).read).result)[Drone.env])

# Generally, these should not need to be modified but are declared
# here for readability purposes.
Drone.config.merge!({

  # Location in which to store screen captures
  capture_path: File.join(Drone::ROOT, 'captures'),

  # Path to capturejs script (internal)
  capturejs_path: File.join(Drone::ROOT, 'js/capture.js'),

  # Log level for drone-run process
  log_level: Logger::DEBUG,
  log_device: File.join(Drone::ROOT, 'log', "#{Drone.env}.log"),

  # Prefix used for all keys stores in redis
  redis_key_prefix: "drone-#{Drone.env}-",

  # Location to store temporary files
  tmp_path: File.join(Drone::ROOT, 'tmp', Drone.env),

  # Regex to validate target URLs
  url_validation_regex: /^(http|https)\:\/\//i

})

# Pull in environment-specific config
environment = File.join(Drone::ROOT, "config/environments/#{Drone.env}.rb")
require environment if File.exists?(environment)

# Access token reader
Drone.config.merge!({
  params: {
    'access_token' => Proc.new { Drone::Credential.find_oauth_access_token('default') }
  }
})

# Check directories that should exist
[
  Drone.config[:capture_path],
  Drone.config[:tmp_path]
].each do |path|
  FileUtils.mkdir_p(path) unless Dir.exist?(path)
end

# Mark config as loaded
Drone.config[:loaded] = true

# Load the API and CLI now that the config is set
require 'drone/api'
require 'drone/cli'

# Synchronize credentials with redis
Drone.sync_credentials
