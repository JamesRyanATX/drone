# This needs to stay at the top
$stdout.sync = true
$stderr.sync = true

require 'yaml'
require File.expand_path('../../lib/drone.rb', __FILE__)

Drone.config[:environment] = ENV['RAILS_ENV'] || ENV['DRONE_ENV'] || 'development'

Drone.config.merge!(YAML.load_file(File.join(Drone::ROOT, 'config', 'application.yml'))[Drone.env])

# Generally, these should not need to be modified but are declared
# here for readability purposes.
Drone.config.merge!({

  # Location in which to store screen captures
  capture_path: File.join(Drone::ROOT, 'captures'),

  # Path to capturejs script (internal)
  capturejs_path: File.join(Drone::ROOT, 'js/capture.js'),

  # ImageMagick paths
  imagemagick_convert_path: File.join(Drone::ROOT, 'bin', 'convert'),
  imagemagick_identify_path: File.join(Drone::ROOT, 'bin', 'identify'),

  # Log level for drone-run process
  log_level: Logger::DEBUG,
  log_device: File.join(Drone::ROOT, 'log', "#{Drone.env}.log"),

  # Path to PhantomJS (included in this app by default)
  phantomjs_path: File.join(Drone::ROOT, 'bin', 'phantomjs'),

  # Prefix used for all keys stores in redis
  redis_key_prefix: "drone-#{Drone.env}-",

  # Location to store temporary files
  tmp_path: File.join(Drone::ROOT, 'tmp', Drone.env),

  # Regex to validate target URLs
  url_validation_regex: /^(http|https)\:\/\//i

})

environment = File.join(Drone::ROOT, "config/environments/#{Drone.env}.rb")

require environment if File.exists?(environment)
