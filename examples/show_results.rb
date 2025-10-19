#!/usr/bin/env ruby
require "json"
require "time"

RESULTS_FILE = "performance_results.json"

unless File.exist?(RESULTS_FILE)
  puts "No results found. Run 'ruby examples/benchmark.rb baseline' first."
  exit 1
end

results = JSON.parse(File.read(RESULTS_FILE))

puts "\n" + "=" * 80
puts "PERFORMANCE BENCHMARK RESULTS"
puts "=" * 80

if results.empty?
  puts "\nNo benchmark data available."
  exit 0
end

# Sort by timestamp (most recent first)
sorted_labels = results.keys.sort_by { |label| results[label]["timestamp"] }.reverse

sorted_labels.each do |label|
  data = results[label]
  timestamp = Time.parse(data["timestamp"]).strftime("%Y-%m-%d %H:%M:%S")

  puts "\n#{label.upcase}"
  puts "-" * 80
  puts "Timestamp: #{timestamp}"
  puts ""

  # Display results for each scene
  ["tiny", "small", "medium"].each do |scene|
    next unless data["results"][scene]

    scene_data = data["results"][scene]
    pixels = scene_data["pixels"]
    avg = scene_data["avg"]
    min = scene_data["min"]
    max = scene_data["max"]
    stddev = scene_data["stddev"]
    px_per_sec = scene_data["pixels_per_second"]

    puts "  #{scene.capitalize} Scene:"
    puts "    Resolution:  #{Math.sqrt(pixels * 2).round}×#{Math.sqrt(pixels / 2).round} (#{pixels} pixels)"
    puts "    Average:     #{avg}s"
    puts "    Min/Max:     #{min}s / #{max}s"
    puts "    Std Dev:     #{stddev}s"
    puts "    Throughput:  #{px_per_sec.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} px/s"
    puts ""
  end
end

# Summary comparison if multiple results
if sorted_labels.length > 1
  puts "=" * 80
  puts "COMPARISON SUMMARY"
  puts "=" * 80

  baseline_label = sorted_labels.last  # Oldest (usually baseline)
  latest_label = sorted_labels.first   # Newest

  baseline = results[baseline_label]["results"]
  latest = results[latest_label]["results"]

  puts "\nComparing: #{latest_label} vs #{baseline_label}"
  puts ""

  ["tiny", "small", "medium"].each do |scene|
    next unless baseline[scene] && latest[scene]

    baseline_time = baseline[scene]["avg"]
    latest_time = latest[scene]["avg"]
    speedup = baseline_time / latest_time
    improvement = ((speedup - 1.0) * 100).round(1)

    emoji = speedup > 1.0 ? "🚀" : (speedup < 1.0 ? "🐌" : "➡️")

    puts "  #{emoji} #{scene.capitalize}: #{baseline_time}s → #{latest_time}s (#{speedup.round(2)}x, #{improvement}% #{improvement >= 0 ? 'faster' : 'slower'})"
  end
end

puts "\n" + "=" * 80
puts "Stored in: #{RESULTS_FILE}"
puts "=" * 80
puts ""
