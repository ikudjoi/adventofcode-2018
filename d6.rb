require 'pp'
require 'set'

def mandi(x0, x1, c)
  (x0 - c[0]).abs + (x1 - c[1]).abs
end

coordinates = []
IO.foreach('input6.txt') {|line|
  coordinates.push(line.sub("\n",'').split(', ').map {|s| s.to_i})
}

min_x0 = coordinates.map { |x| x[0] }.min
max_x0 = coordinates.map { |x| x[0] }.max

min_x1 = coordinates.map { |x| x[1] }.min
max_x1 = coordinates.map { |x| x[1] }.max

infinite_areas = Set[]
area_sizes = Array.new(coordinates.length, 0)

number_of_locations_with_total_distance_less_than_10000 = 0

closest_point_grid = Array.new(max_x0-min_x0+1) { Array.new(max_x1-min_x1+1) }
((min_x0)..(max_x0)).each { |x0| 
  ((min_x1)..(max_x1)).each { |x1|
    closest_point_grid[x0 - min_x0][x1 - min_x1] = -1
    distances = coordinates.each_with_index.map {|c, i| [i, mandi(x0, x1, c)] }.sort_by { |d| d[1] }

    number_of_locations_with_total_distance_less_than_10000 += 1 if distances.map {|d| d[1]}.sum < 10000
    min_distance = distances[0]
    second_min_distance = distances[1]
    if min_distance[1] < second_min_distance[1]
      closest_coordinate = min_distance[0]
      closest_point_grid[x0 - min_x0][x1 - min_x1] = closest_coordinate
      area_sizes[closest_coordinate] += 1
      infinite_areas.add(closest_coordinate) if x0 == min_x0 or x0 == max_x0 or x1 == min_x1 or x1 == max_x1
    end
  }
}

finite_area_sizes = area_sizes.dup.each_with_index.map {|s, i| [i, s]}
infinite_areas.sort.reverse.each { |i| finite_area_sizes.delete_at(i) }

pp finite_area_sizes.sort_by { |v| v[1] }.reverse
puts number_of_locations_with_total_distance_less_than_10000
