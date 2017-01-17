require 'spec_helper'

describe Drone::Credential do

  let(:credential) do
    Drone::Credential.from_id('foo', {
      oauth_client_id: 1,
      oauth_client_secret: 2,
      oauth_host: 'http://localhost',
      oauth_redirect_uri: 'http://localhost'
    }).save
  end

  subject { credential }

  describe "#client" do
    it "returns an oauth2 client" do
      expect(subject.client).to be_kind_of(OAuth2::Client)
    end
  end

end