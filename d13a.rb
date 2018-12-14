require 'pp'

module CartTurnDirection
  LEFT = 0
  STRAIGHT = 1
  RIGHT = 2
end

class Cart
  attr_accessor :char

  def initialize(char, id)
    @char = char
    @id = id
    @direction = CartTurnDirection::LEFT
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
    @carts = {}
    # Write input to char array
    cart_id = 1
    y = 0
    input.each { |line|
      x = 0
      line.split('').each { |char|
        @track_grid[x][y] = char
        if is_cart(char)
          #puts "Found cart at coordinates #{x},#{y}."
          @carts[[x,y]] = Cart.new(char, cart_id)
          cart_id += 1
        end
        x += 1
      }
      y += 1
    }

    # Interpolate track grid that is below the carts.
    @carts.keys.each { |l|
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
    raise "Collision at #{x},#{y}!" if @carts.key?([x,y])
    char
  end

  def process_turn
    cart_locations = @carts.keys.dup
    cart_locations.sort_by {|l| l.reverse }.each { |cart_location|
      x = cart_location[0]
      y = cart_location[1]
      cart = @carts[[x,y]]
      raise "Could not find cart!" if cart.nil?
      case cart.char
      when '<'
        next_char = get_next_char_and_check_for_collision(x-1, y)
        case next_char
        when '-'
          cart.char = '<'
        when '\\'
          cart.char = '^'
        when '/'
          cart.char = 'v'
        when '+'
          cart = @carts[[x,y]]
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
        @carts[[x-1,y]] = @carts.delete([x,y])
      when '>'
        next_char = get_next_char_and_check_for_collision(x+1, y)
        case next_char
        when '-'
          cart.char = '>'
        when '\\'
          cart.char = 'v'
        when '/'
          cart.char = '^'
        when '+'
          cart = @carts[[x,y]]
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
        @carts[[x+1,y]] = @carts.delete([x,y])
      when '^'
        next_char = get_next_char_and_check_for_collision(x, y-1)
        case next_char
        when '|'
          cart.char = '^'
        when '\\'
          cart.char = '<'
        when '/'
          cart.char = '>'
        when '+'
          cart = @carts[[x,y]]
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
        @carts[[x,y-1]] = @carts.delete([x,y])
      when 'v'
        next_char = get_next_char_and_check_for_collision(x, y+1)
        case next_char
        when '|'
          cart.char = 'v'
        when '\\'
          cart.char = '>'
        when '/'
          cart.char = '<'
        when '+'
          cart = @carts[[x,y]]
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
        @carts[[x,y+1]] = @carts.delete([x,y])
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
