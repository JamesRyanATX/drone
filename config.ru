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

# Set up static asset server (may or may not apply in production)
use Rack::Static, urls: static_assets

run Drone::API
