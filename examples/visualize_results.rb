#!/usr/bin/env ruby
require "json"
require "time"

RESULTS_FILE = "performance_results.json"
OUTPUT_FILE = "performance_results.html"

unless File.exist?(RESULTS_FILE)
  puts "No results found. Run 'ruby examples/benchmark.rb baseline' first."
  exit 1
end

results = JSON.parse(File.read(RESULTS_FILE))

if results.empty?
  puts "No benchmark data available."
  exit 0
end

# Prepare data for charts
labels = results.keys.sort_by { |label| results[label]["timestamp"] }
scenes = ["tiny", "small", "medium"]

# Extract data for each scene
chart_data = scenes.map do |scene|
  {
    label: scene.capitalize,
    data: labels.map { |label| results[label]["results"][scene]&.[]("avg") }.compact
  }
end

# Calculate speedups relative to first benchmark
baseline_label = labels.first
baseline_data = results[baseline_label]["results"]

speedup_data = scenes.map do |scene|
  {
    label: scene.capitalize,
    data: labels.map do |label|
      current_time = results[label]["results"][scene]&.[]("avg")
      baseline_time = baseline_data[scene]&.[]("avg")
      if current_time && baseline_time
        (baseline_time / current_time).round(2)
      else
        nil
      end
    end.compact
  }
end

# Generate HTML
html = <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ray Tracer Performance Results</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
        }

        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 10px;
            font-size: 2.5em;
        }

        .subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 40px;
            font-size: 1.1em;
        }

        .chart-container {
            position: relative;
            margin-bottom: 50px;
            padding: 30px;
            background: #f8f9fa;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .chart-title {
            font-size: 1.5em;
            color: #333;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 600;
        }

        canvas {
            max-height: 400px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 40px;
        }

        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .stat-card h3 {
            font-size: 1.2em;
            margin-bottom: 15px;
            opacity: 0.9;
        }

        .stat-value {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 0.9em;
            opacity: 0.8;
        }

        .table-container {
            overflow-x: auto;
            margin-top: 40px;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e0e0e0;
        }

        th {
            background: #667eea;
            color: white;
            font-weight: 600;
            position: sticky;
            top: 0;
        }

        tr:hover {
            background: #f8f9fa;
        }

        .speedup-positive {
            color: #10b981;
            font-weight: bold;
        }

        .speedup-negative {
            color: #ef4444;
            font-weight: bold;
        }

        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #e0e0e0;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Ray Tracer Performance Results</h1>
        <p class="subtitle">Benchmark analysis and optimization tracking</p>

        <!-- Render Time Chart -->
        <div class="chart-container">
            <div class="chart-title">Render Time Comparison (seconds, lower is better)</div>
            <canvas id="renderTimeChart"></canvas>
        </div>

        <!-- Speedup Chart -->
        <div class="chart-container">
            <div class="chart-title">Speedup vs Baseline (multiplier, higher is better)</div>
            <canvas id="speedupChart"></canvas>
        </div>

        <!-- Summary Stats -->
        <div class="stats-grid">
HTML

# Add stat cards for best results
best_medium = labels.min_by { |l| results[l]["results"]["medium"]&.[]("avg") || Float::INFINITY }
if best_medium && results[best_medium]["results"]["medium"]
  best_time = results[best_medium]["results"]["medium"]["avg"]
  best_throughput = results[best_medium]["results"]["medium"]["pixels_per_second"]

  baseline_time = baseline_data["medium"]&.[]("avg")
  speedup = baseline_time ? (baseline_time / best_time).round(2) : 0

  html << <<~HTML
            <div class="stat-card">
                <h3>Best Medium Scene Time</h3>
                <div class="stat-value">#{best_time}s</div>
                <div class="stat-label">#{best_medium}</div>
            </div>

            <div class="stat-card">
                <h3>Best Throughput</h3>
                <div class="stat-value">#{best_throughput.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}</div>
                <div class="stat-label">pixels/second</div>
            </div>

            <div class="stat-card">
                <h3>Maximum Speedup</h3>
                <div class="stat-value">#{speedup}x</div>
                <div class="stat-label">vs baseline</div>
            </div>
  HTML
end

html << <<~HTML
        </div>

        <!-- Detailed Results Table -->
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Benchmark</th>
                        <th>Timestamp</th>
                        <th>Scene</th>
                        <th>Avg Time</th>
                        <th>Throughput</th>
                        <th>Speedup</th>
                    </tr>
                </thead>
                <tbody>
HTML

# Add table rows
labels.each do |label|
  data = results[label]
  timestamp = Time.parse(data["timestamp"]).strftime("%Y-%m-%d %H:%M")

  scenes.each do |scene|
    next unless data["results"][scene]

    scene_data = data["results"][scene]
    avg = scene_data["avg"]
    throughput = scene_data["pixels_per_second"].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse

    baseline_time = baseline_data[scene]&.[]("avg")
    speedup = baseline_time ? (baseline_time / avg).round(2) : 1.0
    speedup_class = speedup > 1.0 ? "speedup-positive" : (speedup < 1.0 ? "speedup-negative" : "")
    speedup_text = "#{speedup}x"

    html << <<~HTML
                    <tr>
                        <td><strong>#{label}</strong></td>
                        <td>#{timestamp}</td>
                        <td>#{scene.capitalize}</td>
                        <td>#{avg}s</td>
                        <td>#{throughput} px/s</td>
                        <td class="#{speedup_class}">#{speedup_text}</td>
                    </tr>
    HTML
  end
end

html << <<~HTML
                </tbody>
            </table>
        </div>

        <div class="footer">
            <p>Generated from #{RESULTS_FILE}</p>
            <p>Created: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}</p>
        </div>
    </div>

    <script>
        // Render Time Chart
        const renderTimeCtx = document.getElementById('renderTimeChart').getContext('2d');
        new Chart(renderTimeCtx, {
            type: 'bar',
            data: {
                labels: #{labels.to_json},
                datasets: [
                    {
                        label: 'Tiny Scene',
                        data: #{chart_data[0][:data].to_json},
                        backgroundColor: 'rgba(102, 126, 234, 0.8)',
                        borderColor: 'rgba(102, 126, 234, 1)',
                        borderWidth: 2
                    },
                    {
                        label: 'Small Scene',
                        data: #{chart_data[1][:data].to_json},
                        backgroundColor: 'rgba(118, 75, 162, 0.8)',
                        borderColor: 'rgba(118, 75, 162, 1)',
                        borderWidth: 2
                    },
                    {
                        label: 'Medium Scene',
                        data: #{chart_data[2][:data].to_json},
                        backgroundColor: 'rgba(237, 100, 166, 0.8)',
                        borderColor: 'rgba(237, 100, 166, 1)',
                        borderWidth: 2
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.dataset.label + ': ' + context.parsed.y + 's';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Time (seconds)'
                        }
                    }
                }
            }
        });

        // Speedup Chart
        const speedupCtx = document.getElementById('speedupChart').getContext('2d');
        new Chart(speedupCtx, {
            type: 'line',
            data: {
                labels: #{labels.to_json},
                datasets: [
                    {
                        label: 'Tiny Scene',
                        data: #{speedup_data[0][:data].to_json},
                        borderColor: 'rgba(102, 126, 234, 1)',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'Small Scene',
                        data: #{speedup_data[1][:data].to_json},
                        borderColor: 'rgba(118, 75, 162, 1)',
                        backgroundColor: 'rgba(118, 75, 162, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'Medium Scene',
                        data: #{speedup_data[2][:data].to_json},
                        borderColor: 'rgba(237, 100, 166, 1)',
                        backgroundColor: 'rgba(237, 100, 166, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.dataset.label + ': ' + context.parsed.y + 'x faster';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Speedup Multiplier'
                        },
                        ticks: {
                            callback: function(value) {
                                return value + 'x';
                            }
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>
HTML

File.write(OUTPUT_FILE, html)

puts "\n✅ Performance visualization created!"
puts "📊 Open in browser: file://#{File.absolute_path(OUTPUT_FILE)}"
puts ""
