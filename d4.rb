require 'date'
require 'pp'

events = {}
IO.foreach('c:/temp/input4.txt') {|line|
  dt = DateTime::strptime(line[1..16], "%Y-%m-%d %H:%M")
  event = line[19..-2]
  events[dt] = event
}

guards = {}
sleeping_span = nil
sleeping_spans = nil
shift_begin = nil
guard = nil
total_time_sleeping = nil

def update_guard(guards, guard, shift_begin, sleeping_spans, total_time_sleeping)
  # Save info of previous guard
  raise "prkl #{guard} #{total_time_sleeping}" if sleeping_spans.length == 0
  if guards[guard].nil?
    guards[guard] = { "id" => guard, "total_time_sleeping" => total_time_sleeping, "shifts" => { shift_begin => sleeping_spans } } 
  else
    guards[guard]["shifts"][shift_begin] = sleeping_spans
    guards[guard]["total_time_sleeping"] += total_time_sleeping
  end
end

events.sort_by {|dt, e| dt }.each { |dt, e|
  #puts "#{dt} #{e}"
  if e.start_with?('Guard #')
    update_guard(guards, guard, shift_begin, sleeping_spans, total_time_sleeping) unless guard.nil? or total_time_sleeping == 0
    #raise "#{guard} #{total_time_sleeping} #{sleeping_spans.length}" if not guard.nil? and total_time_sleeping > 0 and sleeping_spans == 0
    total_time_sleeping = 0
    shift_begin = dt
    guard = e.split(' ')[1][1..-1].to_i
    sleeping_spans = []
    next
  end

  if e == 'falls asleep'
    sleeping_span = [dt]
  elsif e == 'wakes up'
    sleeping_span << dt
    #puts "#{sleeping_span[0]} #{sleeping_span[1]}"
    sleeping_spans.push(sleeping_span)
    #puts sleeping_spans.length
    total_time_sleeping += ((dt - sleeping_span[0])*24*60*60).to_i
  else
    raise 'Invalid event'
  end
}

# Save info of previous guard
update_guard(guards, guard, shift_begin, sleeping_spans, total_time_sleeping)

#most_sleeping_guard = guards.sort_by {|g, v| v["total_time_sleeping"]}.reverse[0]
#sleeping_ranges = most_sleeping_guard[1]["shifts"].map { |sb, spans| 
#  spans.map { |span|
#    ((span[0].strftime('%M').to_i)..(span[1].strftime('%M').to_i - 1)).to_a
#  }
#}

#puts guards.to_a[0][1]["shifts"]
guards_minutes_sleeping = guards.map {|g, v| { "id" => g, "foo"=> v["shifts"].map { |s, spans| spans.map { |span| ((span[0].strftime('%M').to_i)..(span[1].strftime('%M').to_i - 1)).to_a } }.flatten.inject(Hash.new(0)) {|hash,word| hash[word] += 1; hash }.sort_by { |k,v| v }.reverse[0] } }
pp guards_minutes_sleeping
#guards_minutes_sleeping.map { |g| {"id" => g["id"] }
# ((span[0].strftime('%M').to_i)..(span[1].strftime('%M').to_i - 1)).to_a } } }
  
#puts sleeping_ranges.flatten.inject(Hash.new(0)) {|hash,word| hash[word] += 1; hash }.sort_by { |k,v| v }.reverse[0]
#puts most_sleeping_guard[0]
#puts sleeping_ranges

#puts guards.sort_by {|g, v| v["total_time_sleeping"]}.reverse[0][1]["total_time_sleeping"]
#pp guards.sort_by {|g, v| v["total_time_sleeping"]}[0][1]["shifts"].to_a[0]
#pp guards.sort_by {|g, v| v["total_time_sleeping"]}.map { |g, v| v["total_time_sleeping"] }
#puts guards.map {|g, v| g}.to_a