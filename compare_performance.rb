#!/usr/bin/env ruby
# Performance comparison script between Ruby and Crystal implementations

require 'benchmark'
require 'json'

class PerformanceComparison
  SEPARATOR = "=" * 80

  def initialize
    @results = {
      ruby: {},
      crystal: {},
      comparison: {}
    }
  end

  def run
    puts "\n#{SEPARATOR}"
    puts "Rayz Performance Comparison: Ruby vs Crystal"
    puts SEPARATOR
    puts ""

    check_prerequisites

    puts "This will benchmark the same operations in both Ruby and Crystal."
    puts "Note: Currently only core math operations are implemented in Crystal."
    puts ""

    benchmark_status_display
    benchmark_basic_math if crysta_binary_exists?

    display_results
    save_results
  end

  private

  def check_prerequisites
    # Check Ruby
    unless system("ruby --version > /dev/null 2>&1")
      puts "❌ Ruby not found. Please install Ruby 3.4+"
      exit 1
    end

    # Check Crystal binary
    unless File.exist?("crystal/bin/rayz")
      puts "⚠️  Crystal binary not found."
      puts "   Run: cd crystal && make release"
      puts "   Continuing with Ruby-only benchmarks..."
      @crystal_available = false
    else
      @crystal_available = true
    end
    puts ""
  end

  def crysta_binary_exists?
    @crystal_available
  end

  def benchmark_status_display
    puts "🔍 Benchmarking: Status display"

    # Ruby
    ruby_time = Benchmark.realtime do
      system("./rayz > /dev/null 2>&1", exception: false) ||
      system("ruby examples/run > /dev/null 2>&1")
    end
    @results[:ruby][:status_display] = ruby_time

    # Crystal - rebuild if needed, then time execution only
    if @crystal_available
      # Rebuild first (not timed)
      puts "   Checking if Crystal needs rebuild..."
      system("cd crystal && ./rebuild_if_needed.sh")

      # Now time just the execution
      crystal_time = Benchmark.realtime do
        system("./rayz crystal > /dev/null 2>&1")
      end
      @results[:crystal][:status_display] = crystal_time
      @results[:comparison][:status_display] = ruby_time / crystal_time
    end

    display_benchmark_result("Status Display", ruby_time, @results[:crystal][:status_display])
  end

  def benchmark_basic_math
    puts "\n🔍 Benchmarking: Basic math operations (1M iterations)"

    # Ruby benchmark
    ruby_time = Benchmark.realtime do
      system("ruby -e '
        require \"./lib/rayz\"
        1_000_000.times do
          v1 = Rayz::Vector.new(x: 1, y: 2, z: 3)
          v2 = Rayz::Vector.new(x: 4, y: 5, z: 6)
          v1.cross(v2)
          v1.dot(v2)
          v1.normalize
        end
      '")
    end
    @results[:ruby][:basic_math] = ruby_time

    # Crystal benchmark - will add when we have a benchmark program
    puts "   Ruby:    #{format_time(ruby_time)}"
    puts "   Crystal: Not yet implemented (need benchmark program)"
  end

  def display_benchmark_result(name, ruby_time, crystal_time)
    puts "   Ruby:    #{format_time(ruby_time)}"
    if crystal_time
      puts "   Crystal: #{format_time(crystal_time)}"
      speedup = ruby_time / crystal_time
      puts "   Speedup: #{format_speedup(speedup)}"
    else
      puts "   Crystal: N/A (binary not built)"
    end
  end

  def display_results
    puts "\n#{SEPARATOR}"
    puts "Summary"
    puts SEPARATOR
    puts ""

    if @results[:comparison].any?
      puts "Performance Comparison:"
      @results[:comparison].each do |benchmark, speedup|
        puts "  #{benchmark.to_s.gsub('_', ' ').capitalize}: #{format_speedup(speedup)}"
      end
    else
      puts "Build Crystal binary for performance comparison:"
      puts "  cd crystal && make release"
    end

    puts ""
    puts "Note: Full benchmarks will be available once more chapters are ported."
    puts "      Currently comparing: Basic initialization and status display"
    puts ""
  end

  def save_results
    File.write("performance_comparison.json", JSON.pretty_generate(@results))
    puts "Detailed results saved to: performance_comparison.json"
    puts ""
  end

  def format_time(seconds)
    if seconds < 0.001
      "#{(seconds * 1_000_000).round(2)} μs"
    elsif seconds < 1
      "#{(seconds * 1000).round(2)} ms"
    else
      "#{seconds.round(3)} s"
    end
  end

  def format_speedup(ratio)
    if ratio > 1
      "#{ratio.round(2)}x faster (Crystal)"
    elsif ratio < 1
      "#{(1/ratio).round(2)}x faster (Ruby)"
    else
      "Same speed"
    end
  end
end

if __FILE__ == $0
  PerformanceComparison.new.run
end
