require 'rspec'
require 'rack/test'

ENV['DRONE_ENV'] = 'test'

require File.expand_path('../../config/application.rb', __FILE__)


RSpec.configure do |config|

  config.before :each do
    Drone::Target.reset
  end

  config.after :all do
    Drone::Target.reset
  end

end
