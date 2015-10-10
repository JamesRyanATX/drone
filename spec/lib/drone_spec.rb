require 'spec_helper'

describe Drone do

  describe 'DEFAULT_VIEWPORTS' do
    it "contains default viewport sized" do
      expect(Drone::DEFAULT_VIEWPORTS.keys.sort).to eq([
        :large,
        :pdf_landscape,
        :pdf_portrait,
        :small
      ])
    end
  end

  describe 'ROOT' do
    it "is a valid path" do
      expect(File).to exist(Drone::ROOT)
    end
  end

  describe '.config' do
    it "is a valid hash" do
      expect(Drone.config).to be_kind_of(HashWithIndifferentAccess)
    end
  end

  describe '.logger' do
    it "is a valid logger" do
      expect(Drone.logger).to be_kind_of(Logger)
    end
  end

  describe '.sync_credentials' do
    it "loads credentials into redis" do
      Drone.sync_credentials
      expect(Drone::Credential.count).to eq(1)
    end
  end

  describe '.redis' do
    it "is a valid redis connection" do
      expect(Drone.redis).to be_kind_of(Redis)
    end
  end

  describe '.redis_key' do
    it "constructs a prefixed key" do
      expect(Drone.redis_key('foo')).to eq('drone-test-foo')
    end
  end

end