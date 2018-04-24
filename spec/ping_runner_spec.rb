require 'ostruct'
require 'net/ping'
require 'pry'
require 'timecop'

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

    context "Customized port changes pinger port ivars" do
      let(:options){
        options = ServiceMonitor::CLI.default_options
        options.port = 443
        options
      }

      it { expect(http_pinger.port).to eq(443) }
    end

  end

  context "PingRunner is invoked" do
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

    context "PingRunner measures time" do
      let(:interval) { 10 }
      let(:duration) { 60 }
      let(:start_time) { Time.local(2018, 1, 1, 0, 0, 0) }

      before do
        Timecop.freeze(start_time)
        ping_runner.call
        expect(ping_runner.finished?).to eq(false)
      end

      after do
        Timecop.return
      end

      context "#finished?" do

        it "returns false if the runner is within its duration" do
          Timecop.freeze(start_time + 59.99999)
          expect(ping_runner.finished?).to eq(false)
        end

        it "returns false if the runner's current time is equal to its duration" do
          Timecop.freeze(start_time + 60)
          expect(ping_runner.finished?).to eq(false)
        end

        it "returns true if the runner's current time is greater than its duration" do
          Timecop.freeze(start_time + 60.00001)
          expect(ping_runner.finished?).to eq(true)
        end
      end

    end
    context "#interval_begins_at" do
      let(:interval) { 2.5 }
      it "calculates when the next interval begins based on the runner start time and ping count" do
        expect(ping_runner.interval_begins_at(0)).to eq(start_time)
        expect(ping_runner.interval_begins_at(1)).to eq(start_time + 2.5)
        expect(ping_runner.interval_begins_at(3)).to eq(start_time + 7.5)
      end
    end
  end

end
