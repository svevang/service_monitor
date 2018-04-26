require 'pry'

RSpec.describe ServiceMonitor::OutputFormats::Stdout do
  context "#print_ping" do
    subject(:formatter) { ServiceMonitor::OutputFormats::Stdout.new }
    subject(:ping_printer) { }
    it { expect { formatter.print_ping(0.001)}.to output(/1.0 ms/).to_stdout }
  end
end
