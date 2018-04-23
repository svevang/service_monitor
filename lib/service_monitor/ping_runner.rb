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

    def call
      return -1 unless host_exists?

      pinger = Net::Ping::HTTP.new(host)
      pinger.ping
      puts pinger.duration
    end

  end
end
