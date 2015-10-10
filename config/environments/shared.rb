Drone.config.merge!({
  params: {
    'dasheroo.access_token' => Proc.new { Drone::Credential.find_oauth_access_token('dasheroo') }
  }
})