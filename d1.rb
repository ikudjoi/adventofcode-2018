require 'set'

current_val = 0
met_frequencies = Set[0]

while true do
  IO.foreach('c:/temp/input1.txt') {|line|
  i = line[1..-1].to_i
  val = -i if line[0] == '-'
  val = i if line[0] == '+'

  current_val += val

  #puts "#{line} #{current_val} #{met_frequencies.to_a.to_s}"
  if met_frequencies.include?(current_val)
    raise current_val.to_s
  end

  met_frequencies.add(current_val)

  }
end
