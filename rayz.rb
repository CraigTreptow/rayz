Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| load(f) }

t = Tuple.new(x: 1.0, y: 2.0, z: 3.0, w: 4.0)
puts "X: #{t.x}"
