require 'pp'

dags = []
IO.foreach('input7.txt') { |line| 
  dags.push([line[5], line[36]])
}

steps = 'abcdefghijklmnopqrstuvwxyz'.upcase.split('')
step_durations = steps.map {|s| [s, 61 + s.ord - 'A'.ord]}.to_h
number_of_free_elves = 5
current_time = 0

def step_has_prereqs(step, dags)
  dags.any? { |dag| dag[1] == step }
end

correct_order = []
steps_being_worked = {}

# case 2
while dags.length > 0
  # Remove prereqs that are completed.
  steps_being_worked.select {|s, t| t <= current_time }.each { |s| 
    puts "#{current_time}: Step #{s[0]} finished"
    dags = dags.select { |dag| dag[0] != s[0] }
    steps = steps - [s[0]]
    steps_being_worked.delete(s[0])
    number_of_free_elves += 1
  }

  next_steps_without_prereqs = steps.select { |step| not step_has_prereqs(step, dags) and not steps_being_worked.keys.include?(step) }.sort

  puts "Steps available for work #{next_steps_without_prereqs}."

  # Start processing of as many steps as possible
  next_steps_without_prereqs.each { |step|
    finish_time = current_time + step_durations[step]
    puts "#{current_time}: Starting to work step #{step}. It will be finished by time #{finish_time}. Number of available elves for this task #{number_of_free_elves}."
    steps_being_worked[step] = finish_time
    number_of_free_elves -= 1
    break if number_of_free_elves == 0
  }

  puts "#{current_time}: Number of busy elves #{5-number_of_free_elves}, steps being worked #{steps_being_worked.keys}."
  # Advance time
  current_time = steps_being_worked.values.min
end

# case 1
while dags.length > 0
  next_step_without_prereqs = steps.select { |step| not step_has_prereqs(step, dags) }.sort[0]
  correct_order.push(next_step_without_prereqs)

  # Remove prereqs that are already fulfilled.
  dags = dags.select { |dag| dag[0] != next_step_without_prereqs }
  steps = steps - [next_step_without_prereqs]

  puts correct_order.join('')
end


puts 'abcdefghijklmnopqrstuvwxyz'.upcase.split('') - correct_order
