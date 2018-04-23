require 'ostruct'
require 'optparse'
require 'pry'

module ServiceMonitor
  # Class for parsing command line opts for the service monitor app.
  # Takes in a argv style list of options.
  class CLI

    attr_reader :argv

    def initialize(argv)
      @argv = argv || []
    end

    def call
      options, host = parse(argv)
      #NetworkMonitor::PingRunner.new(host, options)
    end

    # Convert argv into a set of options
    def parse(argv)

      options = OpenStruct.new
      options.duration = 60
      options.interval = 10
      options.request_help = false

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

        opts.on_tail('-h', '--help', 'Show this message') do |is_help|
          options.request_help = is_help
        end
      end

      opt_parser.parse!(argv)
      host = argv.pop

      if options.request_help || !valid?(options, host)
        print_help(opt_parser)
      end

      [options, host]
    end

    def valid?(options, hostname)
      if hostname.nil?
        puts "<hostname> argument is required"
        return false
      end
      true
    end

    private

    def print_help(opts)
      puts 'Service Monitor: Aggregate average response times across service types.'
      puts opts
    end

  end
end
