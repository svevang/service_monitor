require 'ostruct'
require 'pry'

RSpec.describe ServiceMonitor::CLI do
  describe '#parse' do

    let(:argv) { [] }
    subject(:cli) { ServiceMonitor::CLI }

    context 'basic structure' do
      it { is_expected.to respond_to :parse }

      it 'accepts one argument' do
        expect(cli.method(:parse).arity).to be(1)
      end

      it 'returns a set of options' do
        expect(cli.parse(argv).class).to be(OpenStruct)
      end
    end

    context 'options' do
      subject(:options){ cli.parse(argv) }

      context "basic CLI parameters" do
        let(:argv) { ['--duration', '61', '--interval', '8'] }

        it 'accepts a `--duration` argument' do
          expect(options.duration).to eq(61)
        end

        it 'accepts a `--interval` argument' do
          expect(options.interval).to eq(8)
        end
      end

      context "CLI help, print options" do
        before do
          expect(ServiceMonitor::CLI).to receive(:print_help)
        end

        let(:argv) { ["--help"] }

        it 'accepts a `--help` argument' do
          expect(options.help).to eq(true)
        end
      end
    end
  end
end
