#!/usr/bin/env ruby
# frozen_string_literal: true

# Reads benchmark NDJSON results + system info, compares PPM outputs,
# and generates JSON, Markdown, and HTML (Chart.js) report files.
#
# Usage:
#   ruby report.rb --results results.ndjson --system system.json \
#                  --timestamp 2026-05-02T16-00-00 --output-dir ./results

require "cgi"
require "json"
require "optparse"

# ---------------------------------------------------------------------------
# CLI options
# ---------------------------------------------------------------------------
options = {}
OptionParser.new do |opts|
  opts.on("--results PATH") { |v| options[:results] = v }
  opts.on("--system PATH") { |v| options[:system] = v }
  opts.on("--timestamp TS") { |v| options[:timestamp] = v }
  opts.on("--output-dir PATH") { |v| options[:output_dir] = v }
end.parse!

%i[results system timestamp output_dir].each do |key|
  abort "--#{key.to_s.tr("_", "-")} required" unless options[key]
end

# ---------------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------------
raw_runs = File.readlines(options[:results], chomp: true)
  .reject(&:empty?)
  .filter_map.with_index(1) do |line, lineno|
    JSON.parse(line)
rescue JSON::ParserError => e
  warn "WARNING: Skipping malformed NDJSON line #{lineno}: #{e.message}"
  warn "  Content: #{line[0, 120]}"
  nil
  end

abort "ERROR: No valid result lines found in #{options[:results]}" if raw_runs.empty?

system_info = JSON.parse(File.read(options[:system]))
timestamp = options[:timestamp]
output_dir = options[:output_dir]

def h(s) = CGI.escapeHTML(s.to_s)

# ---------------------------------------------------------------------------
# PPM comparison (option B: ±1 per-channel tolerance)
# ---------------------------------------------------------------------------
def parse_ppm_pixels(path)
  content = File.read(path)
  lines = content.split("\n").reject { |l| l.start_with?("#") }
  raise "Empty or comment-only file: #{path}" if lines.empty?
  raise "Not P3 PPM: #{path}" unless lines[0].strip == "P3"
  raise "PPM header too short (#{lines.size} lines): #{path}" if lines.size < 4

  pixels = lines[3..].join(" ").split.map(&:to_i).each_slice(3).to_a
  raise "PPM contains no pixel data: #{path}" if pixels.empty?

  pixels
end

def compare_ppms(path_a, path_b, tolerance: 1)
  pixels_a = parse_ppm_pixels(path_a)
  pixels_b = parse_ppm_pixels(path_b)

  return {match: false, reason: "pixel count mismatch (#{pixels_a.size} vs #{pixels_b.size})"} \
    if pixels_a.size != pixels_b.size

  max_diff = 0
  bad_pixels = 0

  pixels_a.zip(pixels_b).each do |(r1, g1, b1), (r2, g2, b2)|
    diff = [(r1 - r2).abs, (g1 - g2).abs, (b1 - b2).abs].max
    max_diff = [max_diff, diff].max
    bad_pixels += 1 if diff > tolerance
  end

  {
    match: bad_pixels == 0,
    tolerance: tolerance,
    max_channel_diff: max_diff,
    mismatched_pixels: bad_pixels,
    total_pixels: pixels_a.size
  }
end

# ---------------------------------------------------------------------------
# Aggregate: group runs by language+variant+scene, compute stats
# ---------------------------------------------------------------------------
# Key: [language, variant, scene]  =>  array of elapsed times + metadata
grouped = Hash.new { |h, k| h[k] = [] }
raw_runs.each do |run|
  key = [run["language"], run["variant"], run["scene"]]
  grouped[key] << run
end

aggregated = grouped.map do |(lang, variant, scene), runs|
  times = runs.map { |r| r["elapsed"] }
  avg = times.sum / times.size.to_f
  stddev = Math.sqrt(times.map { |t| (t - avg)**2 }.sum / times.size)

  first = runs.min_by { |r| r["iteration"] }

  {
    language: lang,
    language_version: first["language_version"],
    variant: variant,
    variant_desc: first["variant_desc"],
    scene: scene,
    width: first["width"],
    height: first["height"],
    iterations: times,
    avg_seconds: avg.round(4),
    min_seconds: times.min.round(4),
    max_seconds: times.max.round(4),
    stddev_seconds: stddev.round(4),
    pixels_per_second: (first["width"] * first["height"] / avg).round(0),
    ppm_path: first["ppm_path"]
  }
end.sort_by { |r| [%w[small medium large].index(r[:scene]) || 99, r[:avg_seconds]] }

# ---------------------------------------------------------------------------
# PPM comparisons
# Compares the first-iteration PPM of every language for each scene.
# Within-language variant consistency is also checked.
# ---------------------------------------------------------------------------
scenes = %w[small medium large]
ppm_comparisons = []

scenes.each do |scene|
  scene_runs = aggregated.select { |r| r[:scene] == scene }
  next if scene_runs.empty?

  # Cross-language: compare first variant of each language
  by_lang = scene_runs.group_by { |r| r[:language] }
  lang_representatives = by_lang.transform_values do |runs|
    runs.min_by { |r| r[:variant] }
  end

  lang_pairs = lang_representatives.keys.combination(2).to_a
  lang_pairs.each do |(lang_a, lang_b)|
    rep_a = lang_representatives[lang_a]
    rep_b = lang_representatives[lang_b]

    unless File.exist?(rep_a[:ppm_path]) && File.exist?(rep_b[:ppm_path])
      ppm_comparisons << {
        scene: scene, type: "cross-language",
        lang_a: "#{lang_a}:#{rep_a[:variant]}", lang_b: "#{lang_b}:#{rep_b[:variant]}",
        match: nil, reason: "PPM file(s) not found"
      }
      next
    end

    result = begin
      compare_ppms(rep_a[:ppm_path], rep_b[:ppm_path])
    rescue => e
      {match: nil, reason: "PPM parse error: #{e.message}"}
    end
    ppm_comparisons << {
      scene: scene,
      type: "cross-language",
      lang_a: "#{lang_a}:#{rep_a[:variant]}",
      lang_b: "#{lang_b}:#{rep_b[:variant]}",
      **result
    }
  end

  # Within-language: verify all variants produce identical images
  by_lang.each do |lang, runs|
    next if runs.size < 2

    ref = runs.min_by { |r| r[:variant] }
    runs.reject { |r| r[:variant] == ref[:variant] }.each do |other|
      unless File.exist?(ref[:ppm_path]) && File.exist?(other[:ppm_path])
        ppm_comparisons << {
          scene: scene, type: "within-language",
          lang_a: "#{lang}:#{ref[:variant]}", lang_b: "#{lang}:#{other[:variant]}",
          match: nil, reason: "PPM file(s) not found"
        }
        next
      end

      result = begin
        compare_ppms(ref[:ppm_path], other[:ppm_path])
      rescue => e
        {match: nil, reason: "PPM parse error: #{e.message}"}
      end
      ppm_comparisons << {
        scene: scene,
        type: "within-language",
        lang_a: "#{lang}:#{ref[:variant]}",
        lang_b: "#{lang}:#{other[:variant]}",
        **result
      }
    end
  end
end

# ---------------------------------------------------------------------------
# Full JSON report
# ---------------------------------------------------------------------------
report = {
  date: timestamp.sub(/T(\d{2})-(\d{2})-(\d{2})$/, "T\\1:\\2:\\3"),
  machine: system_info,
  scene_description: "Checkers floor (reflective 0.3) + glass sphere + mirror sphere + " \
                     "matte sphere + green cylinder; 1 point light at (-10,10,-10)",
  scene_shapes: ["Plane (checkers pattern)", "Sphere (glass, transparency=0.9, reflective=0.9)",
    "Sphere (mirror, reflective=0.8)", "Sphere (matte, red)",
    "Cylinder (green, closed, y=0..2)"],
  results: aggregated,
  ppm_comparison: ppm_comparisons
}

ts = options[:timestamp]
json_path = File.join(output_dir, "#{ts}.json")
File.write(json_path, JSON.pretty_generate(report))
puts "  Written: #{json_path}"

# ---------------------------------------------------------------------------
# Markdown report
# ---------------------------------------------------------------------------
def fmt_seconds(s)
  (s < 1) ? "#{(s * 1000).round(1)} ms" : "#{s.round(3)} s"
end

md_lines = []
md_lines << "# Ray Tracer Benchmark — #{ts.sub(/T(\d{2})-(\d{2})-(\d{2})$/, " \\1:\\2:\\3")}"
md_lines << ""
md_lines << "## Machine"
md_lines << ""
si = report[:machine]
md_lines << "| Field | Value |"
md_lines << "|---|---|"
md_lines << "| Hostname | #{si["hostname"]} |"
md_lines << "| CPU | #{si["cpu_model"]} |"
md_lines << "| Cores | #{si["cpu_cores"]} |"
md_lines << "| Memory | #{si["memory_gb"]} GB |"
md_lines << "| OS | #{si["os"]} |"
md_lines << ""
md_lines << "## Scene"
md_lines << ""
md_lines << report[:scene_description]
md_lines << ""
report[:scene_shapes].each { |s| md_lines << "- #{s}" }
md_lines << ""
md_lines << "## Results"

%w[small medium large].each do |scene|
  md_lines << ""
  md_lines << "### #{scene.capitalize}"
  md_lines << ""
  md_lines << "| Language | Variant | W×H | Avg | Min | Max | Std Dev | Px/s |"
  md_lines << "|---|---|---|---|---|---|---|---|"
  aggregated.select { |r| r[:scene] == scene }.each do |r|
    dims = "#{r[:width]}×#{r[:height]}"
    md_lines << "| #{r[:language]} (#{r[:language_version].split.first(2).join(" ")}) " \
                "| #{r[:variant]} | #{dims} " \
                "| #{fmt_seconds(r[:avg_seconds])} | #{fmt_seconds(r[:min_seconds])} " \
                "| #{fmt_seconds(r[:max_seconds])} | #{fmt_seconds(r[:stddev_seconds])} " \
                "| #{r[:pixels_per_second].to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1,").reverse} |"
  end
end

md_lines << ""
md_lines << "## PPM Comparison"
md_lines << ""
md_lines << "Tolerance: ±1 per channel (accounts for IEEE 754 float rounding between languages)."
md_lines << ""
md_lines << "| Type | A | B | Scene | Match | Max diff | Mismatched px |"
md_lines << "|---|---|---|---|---|---|---|"

ppm_comparisons.each do |c|
  if c[:match].nil?
    md_lines << "| #{c[:type]} | #{c[:lang_a]} | #{c[:lang_b]} | #{c[:scene]} " \
                "| — skipped | #{c[:reason]} | — |"
  else
    match_str = c[:match] ? "✓ yes" : "✗ NO"
    md_lines << "| #{c[:type]} | #{c[:lang_a]} | #{c[:lang_b]} | #{c[:scene]} " \
                "| #{match_str} | #{c[:max_channel_diff]} | #{c[:mismatched_pixels]} / #{c[:total_pixels]} |"
  end
end

md_path = File.join(output_dir, "#{ts}.md")
File.write(md_path, md_lines.join("\n") + "\n")
puts "  Written: #{md_path}"

# ---------------------------------------------------------------------------
# HTML report (Chart.js)
# ---------------------------------------------------------------------------
scene_order = %w[small medium large]
all_variants = aggregated.map { |r| "#{r[:language]}:#{r[:variant]}" }.uniq.sort

# Build dataset series: one per language:variant, values indexed by scene
def chart_dataset(label, data_by_scene, scenes, color)
  values = scenes.map { |s| data_by_scene[s]&.round(4) || 0 }
  {label: label, data: values, backgroundColor: color, borderColor: color, borderWidth: 1}
end

COLORS = %w[
  #4e79a7 #f28e2b #e15759 #76b7b2 #59a14f
  #edc948 #b07aa1 #ff9da7 #9c755f #bab0ac
].freeze

datasets_time = all_variants.each_with_index.map do |var_key, idx|
  by_scene = aggregated.select { |r| "#{r[:language]}:#{r[:variant]}" == var_key }
    .each_with_object({}) { |r, h| h[r[:scene]] = r[:avg_seconds] }
  chart_dataset(var_key, by_scene, scene_order, COLORS[idx % COLORS.size])
end

datasets_pps = all_variants.each_with_index.map do |var_key, idx|
  by_scene = aggregated.select { |r| "#{r[:language]}:#{r[:variant]}" == var_key }
    .each_with_object({}) { |r, h| h[r[:scene]] = r[:pixels_per_second] }
  chart_dataset(var_key, by_scene, scene_order, COLORS[idx % COLORS.size])
end

scene_labels_json = JSON.generate(scene_order)
datasets_time_json = JSON.generate(datasets_time)
datasets_pps_json = JSON.generate(datasets_pps)

ppm_rows_html = ppm_comparisons.map do |c|
  if c[:match].nil?
    "<tr><td>#{h(c[:type])}</td><td>#{h(c[:lang_a])}</td><td>#{h(c[:lang_b])}</td>" \
    "<td>#{h(c[:scene])}</td><td>—</td><td colspan='2'>#{h(c[:reason])}</td></tr>"
  else
    status = c[:match] ? "<td style='color:green'>✓</td>" : "<td style='color:red'>✗</td>"
    "<tr><td>#{h(c[:type])}</td><td>#{h(c[:lang_a])}</td><td>#{h(c[:lang_b])}</td>" \
    "<td>#{h(c[:scene])}</td>#{status}<td>#{c[:max_channel_diff]}</td>" \
    "<td>#{c[:mismatched_pixels]} / #{c[:total_pixels]}</td></tr>"
  end
end.join("\n")

def results_table_html(rows_data, &fmt)
  header = "<thead><tr><th>Language</th><th>Variant</th><th>Size</th>" \
            "<th>Avg</th><th>Min</th><th>Max</th><th>Px/s</th></tr></thead>"
  rows = rows_data.map(&fmt).join("\n")
  "<table>\n  #{header}\n  <tbody>\n#{rows}\n  </tbody>\n</table>"
end

scene_tables_html = %w[small medium large].map do |scene|
  rows = aggregated.select { |r| r[:scene] == scene }
  table = results_table_html(rows) do |r|
    "<tr><td>#{h(r[:language])}</td><td>#{h(r[:variant])}</td>" \
    "<td>#{r[:width]}×#{r[:height]}</td><td>#{fmt_seconds(r[:avg_seconds])}</td>" \
    "<td>#{fmt_seconds(r[:min_seconds])}</td><td>#{fmt_seconds(r[:max_seconds])}</td>" \
    "<td>#{r[:pixels_per_second].to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1,").reverse}</td></tr>"
  end
  "<h3>#{scene.capitalize}</h3>\n#{table}"
end.join("\n\n")

html = <<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Ray Tracer Benchmark — #{ts}</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
    <style>
      body { font-family: sans-serif; max-width: 1100px; margin: 2rem auto; padding: 0 1rem; color: #222; }
      h1   { font-size: 1.5rem; }
      h2   { font-size: 1.2rem; margin-top: 2rem; border-bottom: 1px solid #ccc; padding-bottom: .3rem; }
      table { border-collapse: collapse; width: 100%; font-size: .85rem; }
      th, td { border: 1px solid #ddd; padding: .4rem .6rem; text-align: left; }
      th   { background: #f4f4f4; }
      .charts { display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin: 1rem 0; }
      .chart-wrap canvas { max-height: 320px; }
    </style>
  </head>
  <body>
    <h1>Ray Tracer Benchmark — #{ts.sub(/T(\d{2})-(\d{2})-(\d{2})$/, " \\1:\\2:\\3")}</h1>

    <h2>Machine</h2>
    <table>
      <tr><th>Hostname</th><td>#{h(si["hostname"])}</td></tr>
      <tr><th>CPU</th><td>#{h(si["cpu_model"])}</td></tr>
      <tr><th>Cores</th><td>#{h(si["cpu_cores"])}</td></tr>
      <tr><th>Memory</th><td>#{h(si["memory_gb"])} GB</td></tr>
      <tr><th>OS</th><td>#{h(si["os"])}</td></tr>
    </table>

    <h2>Charts</h2>
    <div class="charts">
      <div class="chart-wrap">
        <canvas id="chartTime"></canvas>
      </div>
      <div class="chart-wrap">
        <canvas id="chartPps"></canvas>
      </div>
    </div>

    <h2>Results</h2>
    #{scene_tables_html}

    <h2>PPM Comparison (±1 tolerance per channel)</h2>
    <table>
      <thead><tr>
        <th>Type</th><th>A</th><th>B</th><th>Scene</th>
        <th>Match</th><th>Max diff</th><th>Mismatched px</th>
      </tr></thead>
      <tbody>
        #{ppm_rows_html}
      </tbody>
    </table>

    <script>
      const labels = #{scene_labels_json};

      new Chart(document.getElementById('chartTime'), {
        type: 'bar',
        data: { labels, datasets: #{datasets_time_json} },
        options: {
          plugins: { title: { display: true, text: 'Average render time (seconds, lower is better)' } },
          scales:  { y: { beginAtZero: true, title: { display: true, text: 'seconds' } } }
        }
      });

      new Chart(document.getElementById('chartPps'), {
        type: 'bar',
        data: { labels, datasets: #{datasets_pps_json} },
        options: {
          plugins: { title: { display: true, text: 'Throughput (pixels/second, higher is better)' } },
          scales:  { y: { beginAtZero: true, title: { display: true, text: 'px/s' } } }
        }
      });
    </script>
  </body>
  </html>
HTML

html_path = File.join(output_dir, "#{ts}.html")
File.write(html_path, html)
puts "  Written: #{html_path}"
