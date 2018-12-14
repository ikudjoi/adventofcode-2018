require 'pp'

def power_level(x, y, serial_number = nil)
  my_serial_number = 9306
  serial_number = serial_number || my_serial_number
  rack_id = x + 10
  power_level = rack_id * y
  power_level += serial_number
  power_level *= rack_id
  power_level %= 1000
  power_level = (power_level / 100).to_i
  power_level -= 5
  power_level
end

def find_biggest_subgrid(fuel_levels)
  biggest_sum = nil
  biggest_sum_x = nil
  biggest_sum_y = nil

  region_sums = Array.new(fuel_levels.length - 2) { Array.new(fuel_levels[0].length - 2) }

  (1..(fuel_levels.length - 2)).each { |x|
    (1..(fuel_levels[0].length - 2)).each { |y|
      sum = fuel_levels[((x-1)..(x+1))].map {|v| v[((y-1)..(y+1))].sum }.sum
      if biggest_sum.nil? or sum > biggest_sum
        biggest_sum = sum
        biggest_sum_x = x
        biggest_sum_y = y
      end

      region_sums[x-1][y-1] = sum
    }
  }

  [biggest_sum_x, biggest_sum_y, biggest_sum, region_sums]
end

#test_input = [[3,5,8],[122,79,57],[217,196,39],[101,153,71]]
#test_input.each {|i| puts power_level(*i) }
#exit

fuel_levels = Array.new(300) { Array.new(300) }

(1..300).each { |x|
  (1..300).each { |y|
    fuel_levels[x-1][y-1] = power_level(x, y)
  }
}

sum_data = find_biggest_subgrid(fuel_levels)


puts "#{sum_data[0]},#{sum_data[1]} sum: #{sum_data[2]}"
