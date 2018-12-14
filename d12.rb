require 'pp'

buffer = 25
generation_count = 20
plant_char = '#'

input = """initial state: #..#.#..##......###...### 

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
""".split(/(?<=\n)/)

# Above was example, override input from file.
input = IO.foreach('input12.txt').to_a

initial_state = input[0][15..-3]
#puts initial_state

transformations = input[2..-1].map {|l| l.split(' ')}.map { |a| [a[0], a[2]]}.to_h
#puts transformations
transformation_length = transformations.keys[0].length
influence_zone_length = (transformation_length - 1) / 2

initial_state = ('.' * buffer) + initial_state + ('.' * buffer)
current_state = initial_state.dup
puts "  0: #{current_state}"

(1..generation_count).each { |gen|
  next_state = current_state.dup
  ((influence_zone_length)..(initial_state.length - 1 - influence_zone_length)).each { |pot_index|
  	if (pot_index == influence_zone_length or pot_index == initial_state.length - 1 - influence_zone_length) and current_state[pot_index] == plant_char
  	  raise 'Plants are spreading beyond buffer!'
  	end

  	pot_status = current_state[(pot_index - influence_zone_length)..(pot_index + influence_zone_length)]
  	new_pot_status = transformations[pot_status] || '.'
  	next_state[pot_index] = new_pot_status
  }

  current_state = next_state
  puts "#{gen.to_s.rjust(3,' ')}: #{current_state}"
}

pot_number = -buffer
sum_of_pot_numbers = 0
current_state.split('').each { |pot_status|
  sum_of_pot_numbers += pot_number if pot_status == plant_char
  pot_number += 1
}
puts sum_of_pot_numbers

# Found out that sum grows linearly after 100 generations.
puts 5691+62*(50000000000-100)

