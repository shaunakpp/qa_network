module SystemLoadMetrics
  def self.cpu_usage
    top = `top -l1 | awk '/CPU usage/'`
    top = top.gsub(/[\,a-zA-Z:]/, '').split(' ')
    top[0].to_f
  end

  def self.memory_usage
    top = `top -l1 | awk '/PhysMem/'`
    top = top.gsub(/[\.\,a-zA-Z:]/, '').split(' ').reverse
    ((top[1].to_f / (top[0].to_f + top[1].to_f)) * 100).round(2)
  end

  def self.average_load
    iostat = `iostat -w1 -c 2 | awk '{print $7}'`
    cpu = 0.0
    iostat.each_line.with_index do |line, line_index|
      next if line_index.eql?(0) || line_index.eql?(1) || line_index.eql?(2)

      cpu = line.split(' ').last.to_f.round(2)
    end
    cpu
  end

  def self.active_connections
    `netstat -an | grep :80 |wc -l`.to_i
  end
end
