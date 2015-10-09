require 'drone/concerns/collection'
require 'drone/concerns/model'

class Drone::Credentials
  include Drone::Concerns::Collection
end

class Drone::Credential
  include Drone::Concerns::Model

  record_prefix 'credential'

  digest :url

  attributes do |record|
    {
      scheme: 'oauth2',
      oauth_client_id: nil,
      oauth_client_secret: nil,
      oauth_host: nil,
      oauth_access_token: nil,
      oauth_refresh_token: nil,
      oauth_expires_at: nil,
      oauth_redirect_uri: nil
    }
  end

  validate do |record|
    raise Drone::RecordInvalid, "'oauth2' is the only supported scheme" if record.scheme.to_s.empty?
    raise Drone::RecordInvalid, "missing oauth_client_id" if record.oauth_client_id.to_s.empty?
    raise Drone::RecordInvalid, "missing oauth_client_secret" if record.oauth_client_secret.to_s.empty?
    raise Drone::RecordInvalid, "missing oauth_host" if record.oauth_host.to_s.empty?
    raise Drone::RecordInvalid, "missing oauth_redirect_uri" if record.oauth_redirect_uri.to_s.empty?
  end

  load do |record|
    [
      :oauth_access_token,
      :oauth_refresh_token,
      :oauth_expires_at,
      :oauth_access_token
    ].each do |attribute|
      record.attributes[attribute] = nil if record.attributes[attribute].to_s.empty?
    end
  end

  def client
    @client ||= OAuth2::Client.new(self.oauth_client_id, self.oauth_client_secret, site: self.oauth_host)
  end

  def authorize(code)
    set_token(client.auth_code.get_token(code, redirect_uri: self.oauth_redirect_uri))
    self
  end

  def refresh
    set_token(OAuth2::AccessToken.new(client, nil, { refresh_token: self.oauth_refresh_token }).refresh!)
    self
  end

  def set_token(token)
    self.update_attributes({
      oauth_access_token: token.token,
      oauth_refresh_token: token.refresh_token,
      oauth_expires_at: token.expires_at
    }).save
  end

  def redirect_uri
    "#{self.oauth_redirect_uri}"
  end

  def authorize_uri
    "#{self.oauth_host}/oauth/authorize?client_id=#{self.oauth_client_id}&response_type=code&redirect_uri=#{self.redirect_uri}"
  end

  def authorized?
    !self.oauth_access_token.nil?
  end

  def expired?
    authorized? && Time.at(self.oauth_expires_at.to_i).gmtime <= Time.now.gmtime
  end

end

Drone::Credentials.class_eval do
  model Drone::Credential
end

Drone::Credential.class_eval do
  collection Drone::Credentials
end