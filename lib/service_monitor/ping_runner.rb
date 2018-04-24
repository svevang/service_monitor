require 'resolv'

module ServiceMonitor
  class PingRunner

    attr_reader :host, :options

    def initialize(host, options)
      @host = host
      @options = options
    end

    def host_exists?
      !!Resolv.getaddress(host)
    end

    def setup_pinger
      Net::Ping::HTTP.new(host, port=options.port)
    end

    def call
      return -1 unless host_exists?

      pinger = setup_pinger
      ping_time = do_ping(pinger)
      puts ping_time
      ping_time

    end

    def do_ping(pinger)
      pinger.ping
      pinger.duration
    end

  end
end
