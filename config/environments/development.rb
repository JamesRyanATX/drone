Drone.config.merge!({

  log_device: STDOUT,

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
    'dasheroo.drone_access_token' => Proc.new { |target| 'password' }
  }

})