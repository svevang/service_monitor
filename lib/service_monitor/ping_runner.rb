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

    def call
      return -1 unless host_exists?
      @start_time = Time.now

      pinger = setup_pinger
      ping_time = do_ping(pinger)
      ping_time

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
