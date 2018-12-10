require 'pp'

fh = open('input8.txt')
input = fh.read
fh.close
#input = '2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2'
input = input.split(' ').map {|n| n.to_i}

def read_node(current_index, input)
  quantity_of_child_nodes = input[current_index]
  #puts "child nodes #{quantity_of_child_nodes}"
  current_index += 1
  quantity_of_metadata_entries = input[current_index]
  raise 'Zero metadata' if quantity_of_metadata_entries == 0
  current_index += 1
  #puts "metadata #{quantity_of_metadata_entries}"

  if quantity_of_child_nodes == 0
    sum_of_metadata = input[(current_index)..(current_index + quantity_of_metadata_entries - 1)].sum
    current_index += quantity_of_metadata_entries
    return [current_index, sum_of_metadata]
  end

  child_node_values = []

  (1..quantity_of_child_nodes).each { |n|
    child_result = read_node(current_index, input)
    child_node_values.push(child_result[1])
    current_index = child_result[0]
  }

  node_value = 0
  input[(current_index)..(current_index + quantity_of_metadata_entries - 1)].each { |metadata_value|
    node_value += child_node_values[metadata_value - 1] if metadata_value <= child_node_values.length
  }  

  current_index += quantity_of_metadata_entries
  [current_index, node_value]
end

puts "#{read_node(0, input)} #{input.length}"



#current_index = 0
#while current_index < input.length
#  quantity_of_child_nodes = input[current_index]
#  puts "child nodes #{quantity_of_child_nodes}"
#  current_index += 1
#  quantity_of_metadata_entries = input[current_index]
#  raise 'Zero metadata' if quantity_of_metadata_entries == 0
#  puts "metadata #{quantity_of_metadata_entries}"
#  current_index += 1
#  # Skip child nodes
#  current_index += quantity_of_child_nodes
#  metadata_numbers = input[(current_index)..(current_index + quantity_of_metadata_entries - 1)]
#  puts metadata_numbers.join(',')
#  sum_of_metadata_entries += metadata_numbers.sum
#  current_index += quantity_of_metadata_entries
#end

#puts sum_of_metadata_entries