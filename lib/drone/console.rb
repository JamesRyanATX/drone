require 'terminal-table'

class Drone::Console

  def self.config
    Terminal::Table.new({ title: "Drone Configuration" }) do |t|
      Drone.config.each do |k, v|
        t << [ k, v.inspect ]
      end

    end
  end

  def self.status
    status = Drone::Status.all
    output = []

    output << Terminal::Table.new({ title: "Queue Sizes" }) do |t|
      t << [ 'Pending', Drone::Target.queue_size(:pending) ]
      t << [ 'Processing', Drone::Target.queue_size(:processing) ]
      t << [ 'Completed', Drone::Target.queue_size(:completed) ]
      t << [ 'Error', Drone::Target.queue_size(:error) ]
    end

    output << Terminal::Table.new({ title: "System Status" }) do |t|
      t << [ 'Target Count', status[:target_count] ]
      t << [ 'Capture Count', status[:capture_count] ]
      t << [ 'Capture Average', status[:capture_average] ]
      t << [ 'Capture Rate', status[:capture_rate] ]
      t << [ 'Error Count', status[:error_count] ]
      t << [ 'Error Rate', status[:error_rate] ]
    end

    output.join("\n\n")
  end

  def self.targets(targets = [])
    Terminal::Table.new({ title: "Drone Targets (#{targets.length})" }) do |t|
      t << [ :id, :url, :capture_count, :created_at, :last_capture_at, :capture_ready_method, :target_status ]
      t << :separator

      targets.each do |target|
        t << [
          target.id,
          target.url,
          target.capture_count,
          target.created_at,
          target.last_capture_at,
          target.capture_ready_method,
          target.target_status
        ]
      end
    end
  end

end