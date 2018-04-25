module ServiceMonitor
  module OutputFormats
    class Stdout
      def print_statistics(stats)
        puts ""
        puts "count:   #{stats[:count]} pings"
        puts "min:     #{formatted_milli(stats[:min])}"
        puts "max:     #{formatted_milli(stats[:max])}"
        puts "stddev:  #{formatted_milli(stats[:stddev])}"
        puts "average: #{formatted_milli(stats[:average])}"

        puts "p95:     #{formatted_milli(stats[:p95])}"
        puts "p99:     #{formatted_milli(stats[:p99])}"
      end

      def print_ping(seconds)
        puts formatted_milli(seconds)
      end

    private

      def formatted_milli(seconds)
        millis = (seconds * 1000).round(2)
        "#{millis} ms"
      end
    end
  end
end
