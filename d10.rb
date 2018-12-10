require 'pp'

class Point
  def initialize(x0, x1, v0, v1)
    @x0 = x0
    @x1 = x1
    @v0 = v0
    @v1 = v1
  end

  def increment_time
    @x0 += @v0
    @x1 += @v1
  end

  def x0
    @x0
  end

  def x1
    @x1
  end

  def distance(other)
    Math.sqrt((x0-other.x0)**2 + (x1-other.x1)**2)
  end
end

points = []
IO.foreach('input10.txt') { |line| 
  coordinates = line[10..23].gsub(' ', '').split(',').map {|v| v.to_i }
  velocity = line[36..43].gsub(' ', '').split(',').map {|v| v.to_i }
  points.push(Point.new(coordinates[0], coordinates[1], velocity[0], velocity[1]))
}

time = 0

while (true) do
  # Move points forward.
  points.each { |p| p.increment_time }
  time += 1

  x0mm = points.map { |p| p.x0 }.minmax
  x0diff = (x0mm[0] - x0mm[1]).abs
  x1mm = points.map { |p| p.x1 }.minmax
  x1diff = (x1mm[0] - x1mm[1]).abs
  next if x0diff > 200 or x1diff > 200
  break
end

100.times do
  # Move points forward.
  points.each { |p| p.increment_time }
  time += 1

  total_distance_to_closest_points = points.map { |p1|
    points.select { |p2| p2 != p1 }.map { |p2| p2.distance(p1) }.min
  }.sum

  if total_distance_to_closest_points <= points.length
    x0mm = points.map { |p| p.x0 }.minmax
    x1mm = points.map { |p| p.x1 }.minmax
    ((x0mm[0])..(x0mm[1])).each { |x0|
      ((x1mm[0])..(x1mm[1])).to_a.reverse.each { |x1|
        is_at_point = points.any? { |p| p.x0 == x0 && p.x1 == x1 }
        print 'X' if is_at_point
        print ' ' unless is_at_point
      }

      puts ''
    }

    raise "#{time}"
  end
end