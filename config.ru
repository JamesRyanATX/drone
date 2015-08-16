require "./config/application.rb"

# Set up static asset server (may or may not apply in production)
use Rack::Static, urls: [
  '/stylesheets',
  '/javascripts',
  '/images'
], root: 'public'

run Drone::API
