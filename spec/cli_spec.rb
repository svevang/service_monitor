require 'ostruct'
require 'pry'

RSpec.describe ServiceMonitor::CLI do

  describe '#parse' do

    let(:argv) { ['gitlab.com'] }
    subject(:cli) { ServiceMonitor::CLI.new(argv) }

    context 'Instantiation' do
      it { is_expected.to respond_to :parse }

      it 'accepts one argument' do
        expect(cli.method(:parse).arity).to be(1)
      end

      it 'returns a tuple of options and arguments' do
        options, arguments = cli.parse(argv)
        expect(options.class).to be(OpenStruct)
      end
    end

    context "#valid?" do

    end

    context 'argv arguments and options' do
      subject(:parsed_args){ cli.parse(argv) }
      subject(:options){ parsed_args[0] }
      subject(:host){ parsed_args[1] }

      let(:argv) { ['--port', '9999', '--duration', '61', '--interval', '8', 'gitlab.com'] }

      it 'accepts a `--port` argument' do
        expect(options.port).to eq(9999)
      end

      it 'accepts a `--duration` argument' do
        expect(options.duration).to eq(61)
      end

      it 'accepts a `--interval` argument' do
        expect(options.interval).to eq(8)
      end

      it 'accepts a host argument' do
        expect(host).to eq('gitlab.com')
      end

      context "CLI help, print options" do
        before do
          expect_any_instance_of(ServiceMonitor::CLI).to receive(:print_help)
        end

        let(:argv) { ["--help"] }

        it 'accepts a `--help` argument' do
          expect(options.request_help).to eq(true)
        end

        it 'sets `request_help` if no args supplied' do
          argv.clear
          expect(argv).to eq([])
          expect(options.request_help).to eq(true)
        end
      end

    end
  end
end
