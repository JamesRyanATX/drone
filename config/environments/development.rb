require File.expand_path('../shared.rb', __FILE__)

Drone.config.merge!({
  log_device: STDOUT,
  log_level: Logger::DEBUG
})