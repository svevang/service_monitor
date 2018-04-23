require 'ostruct'
require 'optparse'
require 'pry'

module ServiceMonitor
  # Class for parsing command line opts for the service monitor app.
  # Takes in a argv style list of options.
  class CLI

    # Convert argv into a set of options
    def self.parse(argv)

      options = OpenStruct.new
      options.duration = 60
      options.interval = 10
      options.help = false

      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: service_monitor [options]'

        opts.separator ''
        opts.separator 'Specific options:'

        opts.on('--duration N', Float, 'Total duration in seconds of this service testing cycle') do |duration|
          options.duration = duration
        end

        opts.on('--interval N', Float, 'Time in seconds between individual service tests (pings).') do |interval|
          options.interval = interval
        end

        opts.on_tail('-h', '--help', 'Show this message') do |is_help|
          options.help = is_help
          self.print_help(opts)
        end
      end

      res = opt_parser.parse!(argv)

      options
    end

    private

    def self.print_help(opts)
      puts 'Service Monitor: Aggregate average response times across service types.'
      puts opts
    end

  end
end
