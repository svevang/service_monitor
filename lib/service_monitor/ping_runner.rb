require "resolv"
require "descriptive_statistics"

module ServiceMonitor
  class PingRunner
    def initialize(host, options)
      @host = host
      @options = options
      @start_time = nil
      @output_format = ServiceMonitor::OutputFormats::Stdout.new
      @pinger = setup_pinger
      @results = []
      @errors = []
    end

    def run!
      return -1 unless host_exists?
      start!

      results.clear
      errors.clear
      num_intervals.times do |i|
        break if finished?

        do_ping!

        sleep(seconds_until_interval(i + 1))
      end

      output_format.print_statistics(statistics)

      results
    end

    def statistics
      return if results.empty?
      {
        :count => results.length,
        :errors => errors.length,
        :min => results.min,
        :max => results.max,
        :stddev => results.standard_deviation,
        :average => results.mean,
        :p95 => results.percentile(95),
        :p99 => results.percentile(99)
      }
    end

  private

    attr_reader :host, :options, :start_time, :results, :errors, :output_format, :pinger

    def host_exists?
      !!Resolv.getaddress(host)
    end

    def setup_pinger
      Net::Ping::HTTP.new(host, port = options.port, timeout=options.interval)
    end

    def seconds_until_interval(ping_offset)
      sleep_time =  interval_begins_at(ping_offset) - Time.now
      # in the case where the ping timeout is longer than the interval
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

    def do_ping!
      pinger.ping
      if pinger.exception
        errors.push(pinger.exception)
        output_format.print_error(pinger.exception)
      else
        results.push(pinger.duration)
        output_format.print_ping(pinger.duration)
      end
    end

    def started?
      !!start_time
    end

    def finished?
      Time.now > start_time + options.duration
    end
  end
end
