# A class handling database migrations
class Area
  def id
    @id
  end

  def coord
    @coord
  end

  def size
    @size
  end

  def initialize(str)
    a = str.split(' ')
    @id = a[0][1..-1].to_i
    @coord_s = a[2][0..-2]
    @coord = @coord_s.split(',').map {|v| v.to_i }
    @size_s = a[3]
    @size = @size_s.split('x').map {|v| v.to_i }
  end
end

areas = IO.foreach('c:/temp/input.txt').map {|line| Area.new(line)}

row, col, default_value = 1000, 1000, 0
counts = Array.new(row){Array.new(col,default_value)}

areas.each {|a|
  (a.coord[0]..(a.coord[0] + a.size[0] - 1)).each {|x0|
    (a.coord[1]..(a.coord[1] + a.size[1] - 1)).each {|x1|
      counts[x0-1][x1-1] = counts[x0-1][x1-1] + 1
    }
  }
}

print "#{counts.flatten.select {|v| v > 1}.length}\n"

areas.each {|a|
  overlaps = false
  (a.coord[0]..(a.coord[0] + a.size[0] - 1)).each {|x0|
    (a.coord[1]..(a.coord[1] + a.size[1] - 1)).each {|x1|
      overlaps = true if counts[x0-1][x1-1] > 1
    }
  }

  next if overlaps
  print a.id
  break
}
