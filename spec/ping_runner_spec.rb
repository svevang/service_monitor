require 'ostruct'
require 'net/ping'
require 'pry'

RSpec.describe ServiceMonitor::PingRunner do
  let(:interval) { 0.0001 }
  let(:duration) { 0.001 }

  let(:options) do 
    options = ServiceMonitor::CLI.default_options
    options.duration = duration
    options.interval = interval
    options
  end
  let(:host) { 'gitlab.com' }
  let(:ping_runner) { ServiceMonitor::PingRunner.new(host, options) }

  context "#setup_pinger" do
    subject(:http_pinger) { ping_runner.setup_pinger }

    it { expect(http_pinger.host).to eq('gitlab.com') }
    it { expect(http_pinger.port).to eq(80) }

    context "custom options changes pinger" do
      let(:options){ 
        options = ServiceMonitor::CLI.default_options
        options.port = 443
        options
      }

      it { expect(http_pinger.port).to eq(443) }
    end

  end

  context "#call" do

    before do
      expect(ping_runner).to receive(:do_ping).with(Net::Ping) { 0.00001 }
    end

    it "expects invocation of#do_ping" do
      expect(ping_runner.call).to eq(0.00001)
    end

    it "sets a start time" do
      ping_runner.call
      expect(ping_runner.start_time).to be_truthy
      expect(ping_runner.start_time.class).to be(Time)
    end

  end
end
