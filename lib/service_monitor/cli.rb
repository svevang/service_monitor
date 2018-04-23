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

      end
      res = opt_parser.parse!(argv)


      options


    end
  end
end
