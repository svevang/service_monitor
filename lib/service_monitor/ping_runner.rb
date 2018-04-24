require 'resolv'

module ServiceMonitor
  class PingRunner

    attr_reader :host, :options, :start_time

    def initialize(host, options)
      @host = host
      @options = options
      @start_time = nil
    end

    def host_exists?
      !!Resolv.getaddress(host)
    end

    def setup_pinger
      Net::Ping::HTTP.new(host, port=options.port)
    end

    def print_ping(ping_time)
        puts ping_time
    end

    def call
      return -1 unless host_exists?
      start!

      results = []
      pinger = setup_pinger
      num_intervals.times do |i|
        break if finished?
        ping_time = do_ping(pinger)
        results.append(ping_time)
        print_ping(ping_time)
        sleep(seconds_until_interval(i+1))
      end
      # TODO return something real here
      results.last

    end

    def seconds_until_interval(ping_offset)
      sleep_time =  interval_begins_at(ping_offset) - Time.now
      # in the case where the timeout is longer than the interval
      if sleep_time < 0
        0
      else
        sleep_time
      end
    end

    def start!
      @start_time ||= Time.now
    end

    def interval_begins_at(ping_offset)
      start_time + (options.interval * ping_offset)
    end

    def num_intervals
      (options.duration / options.interval.to_f).floor
    end

    def do_ping(pinger)
      pinger.ping
      pinger.duration
    end

    def started?
      !!start_time
    end

    def finished?
      Time.now > start_time + options.duration
    end

  end
end
