require_relative "lib/util"
require_relative "lib/tuple"
require_relative "lib/point"

Dir[File.join(__dir__, "{lib,rayz}", "**", "*.rb")].sort.each { |file| require_relative file }

# Chapter1.run

canvas = Canvas.new(width: 5, height: 3)

white = Color.new(red: 1.0, green: 1.0, blue: 1.0)
Color.new(red: 1.0, green: 0, blue: 0)
green = Color.new(red: 0, green: 1.0, blue: 0)
blue = Color.new(red: 0, green: 0, blue: 1.0)

canvas.write_pixel(row: 0, col: 0, color: white)
canvas.write_pixel(row: 1, col: 2, color: blue)
canvas.write_pixel(row: 2, col: 4, color: green)
puts "Canvas..."
puts canvas

# puts "Color..."
# puts canvas.pixels[0][0]
# puts canvas.pixels[4][2]
# puts "Done"
# ppm = canvas.to_ppm
# puts "-" * 20
# puts canvas.to_ppm
# puts "\n"
# puts "-" * 20
# puts ppm[0..6]
