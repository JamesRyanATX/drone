require File.expand_path('../shared.rb', __FILE__)

Drone.config.merge!({
  
  # Log overrides for test envs
  log_device: STDOUT,
  log_level: Logger::DEBUG,

  # Replacement variables for URLs.  Any param declared here
  # will be replaced in URLs automatically.
  #
  # params: {
  #   foo: 'bar'
  # }
  #
  # http://www.ohai.com/${foo}/ => http://www.ohai.com/bar/
  #
  # Values can also be Procs:
  #
  # params: {
  #   foo: Proc.new { |target| target.id }
  # }
  params: {
    'test.test_proc_param' => Proc.new { |target| 'password' }
  },
  
  # Allow "file://" when running tests
  url_validation_regex: /^(http|https|file)\:\/\//i

})