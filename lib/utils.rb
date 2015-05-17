module Ot::Utils 
  class << self
    def map(x, in_min, in_max, out_min, out_max)
      return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    end

    def simple_now
      DateTime.now.strftime("%Y%m%d%H%M%S")
    end

    def random_basenme
      [
        Thread.current.object_id,
        Process.pid,
        SecureRandom.random_number(1 << 32)
      ].join('.')
    end
  end
end
