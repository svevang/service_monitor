module ServiceMonitor
  module PrintUtils
    def self.formatted_milli(second)
      millis = (second * 1000).round(2)
      "#{millis} ms"
    end
  end
end
