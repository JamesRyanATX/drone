require 'spec_helper'

describe "concurrency benchmarks" do
  let(:benchmark) { :baseline }
  let(:url) { 'file://' + File.join(Drone::ROOT, "spec/fixtures/benchmark_#{benchmark}.html") }

  CONCURRENCY_TESTS = {
    light: {
      queue_sizes: [ 5, 10 ],
      thread_counts: [ 2 ]
    },
    normal:{
      queue_sizes: [ 100, 1000 ],
      thread_counts: [ 4 ]
    },
    heavy:{
      queue_sizes: [ 1000, 10000, 50000 ],
      thread_counts: [ 32 ]
    },
  }

  CONCURRENCY_TEST = CONCURRENCY_TESTS[(ENV['DRONE_CONCURRENCY_TEST'] || 'light').to_sym]

  before do
    seed_benchmark(benchmark, queue_size)
  end

  subject do    
    measure {
      Drone::Capture.run({
        continuous: false,
        min_capture_interval: 0,
        recipes: Drone::Recipe.all,
        thread_count: thread_count
      })
    }
  end

  CONCURRENCY_TEST[:thread_counts].each do |thread_count|
    CONCURRENCY_TEST[:queue_sizes].each do |queue_size|
      max_execution_time = queue_size * 10

      context "thread_count = #{thread_count}; queue_size = #{queue_size}; max_execution_time = #{max_execution_time}s" do
        let(:max_execution_time) { max_execution_time }
        let(:queue_size) { queue_size }
        let(:thread_count) { thread_count }

        it "finishes within an acceptable time" do
          if subject[:real] > max_execution_time
            Drone.logger.error("benchmark failed in #{subject[:real]}s (expected < #{max_execution_time})")
          else
            Drone.logger.info("benchmark passed in #{subject[:real]}s")
          end

          File.open('tmp/benchmarks', 'a') { |f|
            f.write(subject.merge({
              thread_count: thread_count,
              queue_size: queue_size,
              max_execution_time: max_execution_time
            }).inspect + "\n")
          }

          expect(subject[:real]).to be <= max_execution_time
        end
      end
    end
  end

  def seed_benchmark(benchmark, size)
    size.times { |i| Drone::Target.from_url(benchmark_url(benchmark, i)).save }
  end

  def execute_benchmark
    Drone::Target.all.each do |target|
      target.capture({ recipes: [ Drone::Recipe.from_name(:thumbnail) ] })
    end
  end

  def benchmark_url(benchmark, i)
    "#{url}?i=#{i}"
  end

  def measure(&block)
    measurement = Benchmark.measure { yield }

    { 
      real: measurement.real,
      cpu_system: measurement.cstime,
      cpu_user: measurement.cutime,
      memory: `ps -o rss -p #{$$}`.strip.split.last.to_i * 1024
    }
  end
end