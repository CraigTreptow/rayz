#!/usr/bin/env ruby
require_relative "benchmark"

# Helper script to compare two benchmark runs
if ARGV.length != 2
  puts "Usage: ruby examples/compare_benchmarks.rb <baseline_label> <optimized_label>"
  puts ""
  puts "Example:"
  puts "  ruby examples/compare_benchmarks.rb baseline parallel-render"
  exit 1
end

baseline_label = ARGV[0]
optimized_label = ARGV[1]

begin
  PerformanceBenchmark.compare(baseline_label: baseline_label, optimized_label: optimized_label)
rescue => e
  puts "Error: #{e.message}"
  puts ""
  puts "Available benchmark results:"
  if File.exist?(PerformanceBenchmark::RESULTS_FILE)
    results = JSON.parse(File.read(PerformanceBenchmark::RESULTS_FILE))
    results.keys.each do |label|
      timestamp = results[label]["timestamp"]
      puts "  - #{label} (#{timestamp})"
    end
  else
    puts "  No benchmark results found. Run 'ruby examples/benchmark.rb baseline' first."
  end
  exit 1
end
