require 'thor'
require 'ripl'
require 'awesome_print'

class Drone::CLI < Thor

  # -- option helpers --

  def self.format_option(required = false)
    option :format, type: :string, required: required, desc: 'Format (png or pdf)', default: 'pdf'
  end

  def self.url_option(required = false)
    option :url, type: :string, required: required, desc: 'Target URL'
  end

  def self.id_option(required = false)
    option :id, type: :string, required: required, desc: 'Target ID'
  end

  def self.recipe_option(required = false)
    option :recipe, type: :string, required: required, desc: 'Recipe'
  end

  def self.capture_ready_method_option(required = false)
    option :capture_ready_method, type: :string, required: required, desc: 'Capture ready method (drone or success)', default: 'drone'
  end


  # -- commands --

  desc 'add', 'Add target'
  url_option(true)
  id_option
  def add
    if options[:id]
      target = Drone::Target.from_id(options[:id])
      target.attributes[:url] = options[:url]
    else
      target = Drone::Target.from_url(options[:url])
    end

    ap target.save
  end

  desc 'capture', 'Capture all targets'
  recipe_option
  url_option
  id_option
  def capture
    id = options[:id]
    url = options[:url]
    recipe = options[:recipe]

    recipes = if recipe
      [ Drone::Recipe.from_name(recipe) ]
    else
      Drone::Recipe.all
    end

    targets = if id
      [ Drone::Target.from_id(id) ]
    elsif url
      [ Drone::Target.from_url(url) ]
    else
      Drone::Target.all
    end

    targets.each do |target|
      if target.persisted?
        target.capture({ recipes: Drone::Recipe.all })
      else
        raise Drone::RecordNotFound, "Target not found.  Perhaps you should add it?"
      end
    end
  end

  desc 'config', 'View configuration'
  def config
    ap Drone.config
  end

  desc 'console', 'Drone irb console'
  def console
    Ripl.start :binding => binding
  end

  desc 'credentials', 'View authentication credentials'
  def credentials
    Drone.sync_credentials.each do |credential|
      ap credential.as_json.merge({
        :'authorized?' => credential.authorized?,
        :'expired?' => credential.expired?
      })
    end
  end

  desc 'install', 'Prepare Drone and PhantomJS installation'
  def install
    phantomjs_flavor = `uname -s`.strip == 'Darwin' ? 'osx' : 'ubuntu-14.04-64'

    imagemagick_identify_path = `which identify`.strip
    imagemagick_convert_path = `which convert`.strip

    if imagemagick_identify_path.blank?
      raise "ImageMagick's identify command not found.  Are you sure it's installed?"
    end

    if imagemagick_convert_path.blank?
      raise "ImageMagick's convert command not found.  Are you sure it's installed?"
    end

    [
      "gunzip -c bin/phantomjs-ubuntu-14.04-64.gz > bin/phantomjs-ubuntu-14.04-64",
      "gunzip -c bin/phantomjs-osx.gz > bin/phantomjs-osx",
      "cd bin && ln -sf phantomjs-#{phantomjs_flavor} phantomjs",
      "cd bin && ln -sf #{imagemagick_identify_path} identify",
      "cd bin && ln -sf #{imagemagick_convert_path} convert",
      "mkdir -p tmp/#{Drone.env}",
      "mkdir -p tmp/test",
      "chmod 755 ./bin/phantomjs",
      "./bin/phantomjs -v",
      "./bin/identify -version",
      "./bin/convert -version"
    ].each do |cmd|
      response = `#{cmd} 2>&1`

      puts "#{cmd}"
      puts "-> #{response}" unless response.blank?

      if $?.to_i != 0
        puts "Installation failed. Try running #{cmd} manually before proceeding.".colorize(:red)
        raise Exception, "Installation failed."
      end
    end

    puts "✔ all set, sport".colorize(:green).bold
  end

  desc 'list', 'List targets'
  def list
    puts Drone::Console.targets(Drone::Target.all)
  end

  desc 'remove', 'Remove a single target'
  id_option
  def remove
    Drone::Target.from_id(options[:id]).delete
  end

  desc 'reset', 'Empty target database'
  def reset
    Drone::Target.reset({ queues: %w( pending completed processing error ) })
    Drone::Credential.reset
  end

  desc 'work', 'Run background capturing service'
  def work
    Drone::Capture.run({ continuous: true, recipes: Drone::Recipe.all })
  end

  desc 'status', 'View status'
  def status
    puts Drone::Console.status
  end

end