require 'ostruct'
require 'optparse'
require 'descriptive_statistics'
require 'pry'

module ServiceMonitor
  # Class for parsing command line opts for the service monitor app.
  # Takes in a argv style list of options.
  class CLI

    attr_reader :argv

    def self.default_options(argv=[])
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

      results = ServiceMonitor::PingRunner.new(hostname, options).run!

      p = lambda { |sec| ServiceMonitor::PrintUtils::formatted_milli(sec) }

      puts ""
      puts "min:   #{p.call(results.min)}"
      puts "max:   #{p.call(results.max)}"
      puts "stddev:#{p.call(results.standard_deviation)}"

      puts "p95:   #{p.call(results.percentile(95))}"
      puts "p99:   #{p.call(results.percentile(99))}"

    end

    # Convert argv into a set of options
    def parse(argv)

      options = CLI.default_options(argv)

      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: service_monitor [options] <hostname>'

        opts.separator ''
        opts.separator 'Specific options:'

        opts.on('--duration N', Float, 'Total duration in seconds of this service testing cycle') do |duration|
          options.duration = duration
        end

        opts.on('--interval N', Float, 'Time in seconds between individual service tests (pings).') do |interval|
          options.interval = interval
        end

        opts.on('--port N', Float, 'Port to target in ping test. Default http is port 80') do |port|
          options.port = port
        end

        opts.on_tail('-h', '--help', 'Show this message') do |is_help|
          options.request_help = is_help
        end
      end

      remaining_args = opt_parser.parse!(argv)
      hostname = remaining_args.pop

      if !valid?(options, hostname)
        print_help(opt_parser)
      end

      [options, hostname]
    end

    def valid?(options, hostname)
      return false if options.request_help

      if hostname.nil?
        return false
      end
      true
    end

    private

    def print_help(opts, hostname)
      puts 'Service Monitor: Aggregate average response times across service types.'
      puts opts
      if hostname.nil?
        puts ""
        puts "Hostname argument is missing."
      end
    end

  end
end
