require 'pp'

module CartTurnDirection
  LEFT = 0
  STRAIGHT = 1
  RIGHT = 2
end

class Cart
  attr_accessor :char
  attr_accessor :collided

  def initialize(char, id)
    @char = char
    @id = id
    @direction = CartTurnDirection::LEFT
    @collided = false
  end

  def id
    @id
  end

  def direction
    @direction
  end

  def turned
    @direction = (@direction + 1) % 3
  end
end

class Game
  def char_on_side_not_interferes(char)
    ' |'.include?(char)
  end

  def char_above_or_below_not_interferes(char)
    ' -'.include?(char)
  end

  def initialize(input)
    input = input.split("\n")
    @x_max = input.map { |line| line.length }.max
    @y_max = input.length
    @track_grid = Array.new(@x_max) { Array.new(@y_max) }
    @carts_moving = {}
    @carts_collided = []
    # Write input to char array
    cart_id = 1
    y = 0
    input.each { |line|
      x = 0
      line.split('').each { |char|
        @track_grid[x][y] = char
        if is_cart(char)
          #puts "Found cart at coordinates #{x},#{y}."
          @carts_moving[[x,y]] = Cart.new(char, cart_id)
          cart_id += 1
        end
        x += 1
      }
      y += 1
    }

    # Interpolate track grid that is below the carts.
    @carts_moving.keys.each { |l|
      x = l[0]
      y = l[1]
      raise "Not cart" unless is_cart(try_get_char(x,y))
      #puts "Interpolating grid at #{x},#{y}."
      up_char = try_get_char(x, y-1)
      down_char = try_get_char(x, y+1)
      left_char = try_get_char(x-1, y)
      right_char = try_get_char(x+1, y)

      if char_above_or_below_not_interferes(up_char) and char_above_or_below_not_interferes(down_char)
        @track_grid[x][y] = '-'
      elsif char_on_side_not_interferes(left_char) and char_on_side_not_interferes(right_char)
        @track_grid[x][y] = '|'
      elsif char_on_side_not_interferes(left_char) and char_above_or_below_not_interferes(up_char)
        @track_grid[x][y] = '/'
      elsif char_on_side_not_interferes(right_char) and char_above_or_below_not_interferes(down_char)
        @track_grid[x][y] = '/'
      elsif char_on_side_not_interferes(left_char) and char_above_or_below_not_interferes(down_char)
        @track_grid[x][y] = '\\'
      elsif char_on_side_not_interferes(right_char) and char_above_or_below_not_interferes(up_char)
        @track_grid[x][y] = '\\'
      # This case has been identified by human. Programmatical identification would need more context.
      elsif x == 17 and y == 69
         @track_grid[x][y] = '|'
      else
        raise "Could not interpolate #{x},#{y},#{up_char},#{left_char},#{right_char},#{down_char}."
      end
    }
  end

  def print_grid
    @track_grid.transpose.map(&:join).each { |line| puts line }
  end

  def try_get_char(x, y)
    begin
      return @track_grid[x][y] || ' '
    rescue Exception
    end

    ' '
  end

  def is_cart(char)
    '<>^v'.include?(char)
  end

  def get_next_char_and_check_for_collision(x, y)
    char = @track_grid[x][y]
    raise "Cart out of track #{x},#{y}!" if char.nil? or char == ' ' or char == ''
    if @carts_moving.key?([x,y])
      puts @carts_moving.length
      pp @carts_moving.keys
      puts "Cart getting collided at #{x},#{y}."
      puts "Cart id #{@carts_moving[[x,y]].id}."
      return 'X'
    end
    char
  end

  def handle_collision(from_x, from_y, to_x, to_y)
    cart_hit = @carts_moving[[to_x,to_y]]
    cart_collider = @carts_moving[[from_x,from_y]]
    raise "Error" if cart_hit.nil? or cart_collider.nil?
    puts "Handling collision #{cart_hit.id} by #{cart_collider.id} at #{to_x},#{to_y} from #{from_x},#{from_y}."
    puts "Before delete #{@carts_moving.length}."
    @carts_collided.push([[to_x,to_y], @carts_moving.delete([to_x,to_y])])
    @carts_collided.push([[to_x,to_y], @carts_moving.delete([from_x,from_y])])
    puts "After delete #{@carts_moving.length}."
    if @carts_moving.length == 1
      cart_kvp = @carts_moving.first
      x = cart_kvp[0][0]
      y = cart_kvp[0][1]
      cart = cart_kvp[1]
      raise "One remaining at #{x},#{y} #{cart.id} #{cart.char}."
    end
  end

  def process_turn
    cart_locations = @carts_moving.keys.dup
    cart_locations.sort_by {|l| l.reverse }.each { |cart_location|
      x = cart_location[0]
      y = cart_location[1]
      cart = @carts_moving[[x,y]]
      next if cart.nil?
      case cart.char
      when '<'
        next_char = get_next_char_and_check_for_collision(x-1, y)
        case next_char
        when 'X'
          handle_collision(x, y, x-1, y)
          next
        when '-'
          cart.char = '<'
        when '\\'
          cart.char = '^'
        when '/'
          cart.char = 'v'
        when '+'
          case cart.direction
          when CartTurnDirection::LEFT
            cart.char = 'v'
          when CartTurnDirection::STRAIGHT
            cart.char = '<'
          when CartTurnDirection::RIGHT
            cart.char = '^'
          else
            raise "Invalid direction #{cart.direction}'."
          end
          cart.turned
        else
          raise "Invalid next char '#{x},#{y},#{cart.id},#{next_char},#{cart.char},#{@track_grid[x][y]}'"
        end

        # Update cart location
        @carts_moving[[x-1,y]] = @carts_moving.delete([x,y])
      when '>'
        next_char = get_next_char_and_check_for_collision(x+1, y)
        next if cart.collided
        case next_char
        when 'X'
          handle_collision(x, y, x+1, y)
          next
        when '-'
          cart.char = '>'
        when '\\'
          cart.char = 'v'
        when '/'
          cart.char = '^'
        when '+'
          case cart.direction
          when CartTurnDirection::LEFT
            cart.char = '^'
          when CartTurnDirection::STRAIGHT
            cart.char = '>'
          when CartTurnDirection::RIGHT
            cart.char = 'v'
          else
            raise "Invalid direction #{cart.direction}'."
          end
          cart.turned
        else
          raise "Invalid next char '#{x},#{y},#{cart.id},#{cart.char},#{@track_grid[x][y]}'"
        end

        # Update cart location
        @carts_moving[[x+1,y]] = @carts_moving.delete([x,y])
      when '^'
        next_char = get_next_char_and_check_for_collision(x, y-1)
        next if cart.collided
        case next_char
        when 'X'
          handle_collision(x, y, x, y-1)
          next
        when '|'
          cart.char = '^'
        when '\\'
          cart.char = '<'
        when '/'
          cart.char = '>'
        when '+'
          case cart.direction
          when CartTurnDirection::LEFT
            cart.char = '<'
          when CartTurnDirection::STRAIGHT
            cart.char = '^'
          when CartTurnDirection::RIGHT
            cart.char = '>'
          else
            raise "Invalid direction #{cart.direction}'."
          end
          cart.turned
        else
          raise "Invalid next char '#{x},#{y},#{cart.id},#{cart.char},#{@track_grid[x][y]}'"
        end

        # Update cart location
        @carts_moving[[x,y-1]] = @carts_moving.delete([x,y])
      when 'v'
        next_char = get_next_char_and_check_for_collision(x, y+1)
        next if cart.collided
        case next_char
        when 'X'
          handle_collision(x, y, x, y+1)
          next
        when '|'
          cart.char = 'v'
        when '\\'
          cart.char = '>'
        when '/'
          cart.char = '<'
        when '+'
          case cart.direction
          when CartTurnDirection::LEFT
            cart.char = '>'
          when CartTurnDirection::STRAIGHT
            cart.char = 'v'
          when CartTurnDirection::RIGHT
            cart.char = '<'
          else
            raise "Invalid direction #{cart.direction}'."
          end
          cart.turned
        else
          raise "Invalid next char '#{x},#{y},#{cart.id},#{cart.char},#{@track_grid[x][y]}'"
        end

        # Update cart location
        @carts_moving[[x,y+1]] = @carts_moving.delete([x,y])
      else
        raise "Cart going out of track #{x},#{y}!"
      end
    }
  end
end

fh = open('input13.txt')
input = fh.read
fh.close

game = Game.new(input)
#game.print_grid
loop do
  game.process_turn
end
#game.print_grid
