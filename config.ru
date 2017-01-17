require "./config/application.rb"

# Application prefix
prefix = Drone.config[:prefix]

# Call out static asset URLs so they can be handled before hitting Drone
static_assets = [
  "stylesheets/application.css",
  "javascripts",
  "images"
].inject({}) do |memo, asset|
  if prefix
    memo["/#{prefix}/#{asset}"] = "public/#{asset}"
  else
    memo["/#{asset}"] = "public/#{asset}"
  end

  memo
end

# Uncomment the following to log details about the request pipeline
#class InspectMiddleware
#  require "yaml"
#
#  def initialize(app)
#    @app = app
#  end
#
#  def call(env)
#    puts "Request: " + env['REQUEST_URI']
#    @app.call(env)
#  end
#end
#
#use InspectMiddleware

# Set up static asset server (may or may not apply in production)
use Rack::Static, urls: static_assets

run Drone::API
