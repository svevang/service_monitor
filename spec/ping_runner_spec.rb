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

  context "Invoking the ping runner, application state." do
    before do
      expect(ping_runner).to receive(:do_ping).with(Net::Ping) { 0.00001 }
    end

    context "#do_ping" do
      it "expects invocation of#do_ping" do
        # verifies our stub in the before_hook
        expect(ping_runner.call).to eq(0.00001)
      end
    end

    context "#call" do
      it "sets a start time when the runner is called" do
        expect(ping_runner.start_time).to be_nil
        ping_runner.call
        expect(ping_runner.start_time).to be_truthy
        expect(ping_runner.start_time.class).to be(Time)
      end
    end

    context "#started?" do
      it "returns a boolean if the runner has been started" do
        expect(ping_runner.started?).to eq(false)
        ping_runner.call
        expect(ping_runner.started?).to eq(true)
      end
    end

  end
end
