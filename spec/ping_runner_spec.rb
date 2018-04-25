require "ostruct"
require "net/ping"
require "timecop"

RSpec.describe ServiceMonitor::PingRunner do
  let(:interval) { 0.0001 }
  let(:duration) { 0.001 }

  let(:options) do
    options = ServiceMonitor::CLI.default_options
    options.duration = duration
    options.interval = interval
    options
  end
  let(:host) { "gitlab.com" }
  let(:ping_runner) { ServiceMonitor::PingRunner.new(host, options) }

  before do
    allow(ping_runner).to receive(:host_exists?) { true }
  end

  context "#setup_pinger" do
    subject(:http_pinger) { ping_runner.send(:setup_pinger) }

    it { expect(http_pinger.host).to eq("gitlab.com") }
    it { expect(http_pinger.port).to eq(80) }

    context "Customized port changes pinger port ivars" do
      let(:options) do
        options = ServiceMonitor::CLI.default_options
        options.duration = duration
        options.interval = interval
        options.port = 443
        options
      end

      it { expect(http_pinger.port).to eq(443) }
    end
  end

  context "PingRunner is invoked" do
    context "#do_ping" do
      it "pinger library instance expects invocation of #ping" do
        # mock the pinger class from 'net/ping' and return a fixed duration
        pinger = ping_runner.send(:setup_pinger)
        expect(pinger).to receive(:ping).at_least(:once)
        expect(pinger).to receive(:duration).at_least(:once) { 0.33333 }
        expect(ping_runner.send(:do_ping, pinger)).to eq(0.33333)
      end
    end

    context "#run!" do
      before do
        expect(ping_runner).to receive(:do_ping).at_least(:once).with(Net::Ping) { 0.00001 }
      end

      it "sets a start time when the runner is called" do
        expect(ping_runner.send(:start_time)).to be_nil

        expect { ping_runner.run! }.to output(/0.01 ms/).to_stdout

        expect(ping_runner.send(:start_time)).to be_truthy
        expect(ping_runner.send(:start_time).class).to be(Time)
      end

      it "sets a results ivar after the run" do
        expect { ping_runner.run! }.to output.to_stdout
        expect(ping_runner.send(:results).class).to eq(Array)
      end

      context "#statistics" do
        it "calculates statistics after a run is completed" do
          expect(ping_runner.send(:results)).to eq(nil)
          expect(ping_runner.statistics).to eq(nil)

          expect { ping_runner.run! }.to output(/0.01 ms/).to_stdout

          expect(ping_runner.send(:results).class).to eq(Array)
          expect(ping_runner.statistics.class).to eq(Hash)
        end

        it "calculates a set of interesting statistics" do
          expect { ping_runner.run! }.to output.to_stdout
          stats = ping_runner.statistics
          expect(stats.keys).to eq(%i[count min max stddev average p95 p99])
        end
      end
    end

    context "#started?" do
      it "returns a boolean if the runner has been started" do
        expect(ping_runner.send(:started?)).to eq(false)
        ping_runner.send(:start!)
        expect(ping_runner.send(:started?)).to eq(true)
      end
    end
  end

  context "PingRunner measures time" do
    let(:interval) { 10 }
    let(:duration) { 60 }
    let(:start_time) { Time.local(2018, 1, 1, 0, 0, 0) }

    before do
      Timecop.freeze(start_time)
      ping_runner.send(:start!)
    end

    after do
      Timecop.return
    end

    context "#start!" do
      it "is idemopotent across multiple invocations" do
        expect(ping_runner.send(:start_time)).to eq(start_time)

        # bump the time and restart to see that the old start time remains recorded
        Timecop.freeze(start_time + 1)
        ping_runner.send(:start!)

        expect(ping_runner.send(:start_time)).to eq(start_time)
      end
    end

    context "#finished?" do
      it "returns false if the runner is within its duration" do
        expect(ping_runner.send(:finished?)).to eq(false)
        Timecop.freeze(start_time + 59.99999)
        expect(ping_runner.send(:finished?)).to eq(false)
      end

      it "returns false if the runner's current time is equal to its duration" do
        Timecop.freeze(start_time + 60)
        expect(ping_runner.send(:finished?)).to eq(false)
      end

      it "returns true if the runner's current time is greater than its duration" do
        Timecop.freeze(start_time + 60.00001)
        expect(ping_runner.send(:finished?)).to eq(true)
      end
    end

    context "#interval_begins_at" do
      # choose a funky interval
      let(:interval) { 2.5 }
      it "calculates when the next interval begins based on the runner start time and ping count" do
        expect(ping_runner.send(:interval_begins_at, 0)).to eq(start_time)
        expect(ping_runner.send(:interval_begins_at, 1)).to eq(start_time + 2.5)
        expect(ping_runner.send(:interval_begins_at, 3)).to eq(start_time + 7.5)
      end
    end

    context "#num_intervals" do
      it "calculates how many times the PingRunner will ping" do
        # 10 second intervals over 60 seconds
        expect(ping_runner.send(:num_intervals)).to eq(6)
      end
    end

    context "seconds_until_interval" do
      it "calculates how many seconds until the i'th interval begins" do
        expect(ping_runner.send(:seconds_until_interval, 0)).to eq(0)
        expect(ping_runner.send(:seconds_until_interval, 1)).to eq(10)
        expect(ping_runner.send(:seconds_until_interval, 9)).to eq(90)
      end

      it "should return 0 for negative times" do
        # something way past the current interval
        Timecop.freeze(start_time + 59.99999)
        expect(ping_runner.send(:seconds_until_interval, 1)).to eq(0)
      end
    end
  end
end
