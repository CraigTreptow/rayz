require "../src/rayz"

origin = Rayz::Point.new(0.0, 0.0, 0.0)
direction = Rayz::Vector.new(1.0, 0.0, 0.0)
r = Rayz::Ray.new(origin, direction)

print "Ray positions at t=0,1,2.5: "
[0, 1, 2.5].each { |t| print "#{r.position(t)}  " }
puts

scale = Rayz::Transformations.scaling(2, 3, 4)
r2 = r.transform(scale)
puts "After scaling(2,3,4): origin=#{r2.origin} direction=#{r2.direction}"

puts "\n" + "=" * 60 + "\n"
