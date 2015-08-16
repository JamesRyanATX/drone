require 'cgi'
require 'json'
require 'colorize'
require 'benchmark'

require 'drone/concerns/loggable'

module Drone
  class Phantom
    include Drone::Concerns::Loggable

    attr_accessor :target, :output, :options, :options_path

    def initialize(target, output, options = {})
      @target = target
      @output = output
      @options = {
        ready: target.capture_ready_method,
        recipes: [],
        output: output,
        url: target.capture_url.to_s,
        identify: Drone.config[:imagemagick_identify_path],
        convert: Drone.config[:imagemagick_convert_path],
        thread_id: nil
      }.merge(options)

      raise ArgumentError, 'no recipes specified' if options[:recipes].length == 0

      prepare_recipes
    end

    def capture
      if run_with_benchmark
        log(:info, "Captured #{target.url} (#{target.id}) using ready method '#{target.capture_ready_method}'".colorize(:green))
        true
      else
        log(:error, "Failed to capture #{target.url} (#{target.id}) using ready method '#{target.capture_ready_method}'".colorize(:red))
        false
      end
    end

    private

    def run_with_benchmark
      result = false
      benchmark = Benchmark.measure { result = run }

      log(:debug, "[thread #{options[:thread_id]}] benchmark: #{benchmark.to_s.strip}")

      if result
        Drone::Status.new.log_capture(benchmark.real)
      else
        Drone::Status.new.log_error
      end

      result
    end

    def run
      execute_capture_script do |line|

        # Identified as drone log statement
        if (drone_log = line.match(/^drone.(debug|error|success|info): (.*)$/))
          severity = drone_log[1]
          line = drone_log[2]

        # Normal console output
        else
          severity = 'debug'
          line = "console: #{line}"
        end

        case severity
        when 'success'
          line = line.colorize(:green)
          severity = 'info'
        when 'error'
          line = line.colorize(:red)
        when 'info'
          line = line.colorize(color: :white, mode: :bold)
        end

        log(severity, "[JS] #{line}")
      end

      $?.to_i == 0
    end

    private

    def in_thread?
      !self.options[:thread_id].nil?
    end

    # Mutate recipes to hash for passing to phantomjs
    def prepare_recipes
      self.options[:recipes].map!(&:to_hash)
    end

    def log(severity, message)
      logger.send(severity, (in_thread? ? "[T#{@options[:thread_id]}] " : "") + message)
    end

    def write_options(options)
      json_options = options.to_json
      identifier = Digest::MD5.hexdigest("#{Time.now.to_f}#{json_options}")[0, 8]
      options_path = File.join(Drone.config[:tmp_path], "#{identifier}.json")

      File.open(options_path, 'w') { |f| f.write(json_options) }

      options_path
    end

    def phantomjs_command(options = {})
      @options_path = write_options(options)

      [
        Drone.config[:phantomjs_path],
        ((Drone.config[:phantomjs_ignore_ssl_errors]) ? '--ignore-ssl-errors=true' : nil),
        ((Drone.config[:phantomjs_debug_mode]) ? '--debug=true' : nil),
        '--disk-cache=false',
        '--load-images=true',
        '--local-to-remote-url-access=true',
        Drone.config[:capturejs_path],
        @options_path,
        '2>&1'
      ].compact.join(' ')
    end

    def execute_capture_script(&block)
      IO.popen(phantomjs_command(self.options)) { |io| io.each(&block) }
    end
  end
end
