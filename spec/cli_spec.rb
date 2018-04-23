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
      let(:argv) { ['--duration', '61', '--interval', '8'] }
      subject(:options){ cli.parse(argv) }

      it 'accepts a --duration argument' do
        expect(options.duration).to eq(61)
      end

      it 'accepts a --interval argument' do
        expect(options.interval).to eq(8)
      end
    end
  end
end
