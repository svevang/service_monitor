require "ostruct"
require "optparse"
require "descriptive_statistics"
require "pry"

module ServiceMonitor
  # Class for parsing command line opts for the service monitor app.
  # Takes in a argv style list of options.
  class CLI
    attr_reader :argv

    def self.default_options(argv = [])
      options = OpenStruct.new
      options.duration = 60
      options.interval = 10
      options.request_help = argv.empty?
      options.port = nil
      options
    end

    def initialize(argv)
      @argv = argv || []
    end

    def call
      options, hostname = parse(argv)
      return -1 unless valid?(options, hostname)

      ServiceMonitor::PingRunner.new(hostname, options).run!
    end

    # Convert argv into a set of options
    def parse(argv)
      options = CLI.default_options(argv)

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: service_monitor [options] <hostname>"

        opts.separator ""
        opts.separator "Specific options:"

        opts.on("--duration N", Float, "Total duration in seconds of this service testing cycle") do |duration|
          options.duration = duration
        end

        opts.on("--interval N", Float, "Time in seconds between individual service tests (pings).") do |interval|
          options.interval = interval
        end

        opts.on("--port N", Float, "Port to target in ping test. Default http is port 80 (http).", "Use 443 for a https request.") do |port|
          options.port = port
        end

        opts.on_tail("-h", "--help", "Show this message") do |is_help|
          options.request_help = is_help
        end
      end

      remaining_args = opt_parser.parse!(argv)
      hostname = remaining_args.pop

      print_help(opt_parser, hostname) unless valid?(options, hostname)

      [options, hostname]
    end

    def valid?(options, hostname)
      return false if options.request_help

      return false if hostname.nil?
      true
    end

  private

    def print_help(opts, hostname)
      puts "Service Monitor: Aggregate average response times for a http/s service."
      puts opts
      if hostname.nil?
        puts ""
        puts "Hostname argument is missing."
      end
    end
  end
end
