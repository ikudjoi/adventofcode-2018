require 'pp'

fh = open('input5.txt')
orig_polymer = fh.read[0..-2]
fh.close

result = {}
'abcdefghijklmnopqrstuvwxyz'.split('').each { |char|
  polymer = orig_polymer.dup
  polymer.gsub!(char, '')
  polymer.gsub!(char.upcase, '')

  polymer = polymer.split('') # convert to array
  i = 0
  while(i+1 < polymer.length)
    #puts "#{polymer.length} #{i}"
    if polymer[i].casecmp(polymer[i+1]) == 0 and polymer[i] != polymer[i+1]
      polymer.delete_at(i)
      polymer.delete_at(i)
      if (i > 0)
        i -= 1
      end
    else
      i += 1
    end
  end

  result[char] = polymer.length
}

pp result.sort_by { |k,v| v }

