Drone.config.merge!({
  params: {
    'dasheroo.access_token' => Proc.new { Drone::Credential.from_id('dasheroo').oauth_access_token }
  }
})