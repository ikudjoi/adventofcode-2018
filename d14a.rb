current_scoreboard = '37'
first_elf_location = 0
second_elf_location = 1
puzzle_input = 793031
puzzle_result_length = 10

while current_scoreboard.length < puzzle_input + puzzle_result_length
  first_elf_current_recipe_score = current_scoreboard[first_elf_location].to_i
  second_elf_current_recipe_score = current_scoreboard[second_elf_location].to_i
  new_recipes = first_elf_current_recipe_score + second_elf_current_recipe_score
  current_scoreboard += new_recipes.to_s
  first_elf_location = (first_elf_location + first_elf_current_recipe_score + 1) % current_scoreboard.length
  second_elf_location = (second_elf_location + second_elf_current_recipe_score + 1) % current_scoreboard.length
end

puts current_scoreboard
puts current_scoreboard[(puzzle_input)..(puzzle_input + puzzle_result_length - 1)]