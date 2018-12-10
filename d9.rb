require 'pp'

class MarbleGame
  def initialize(last_marble_id, number_of_players)
    @last_marble_id = last_marble_id
    @number_of_players = number_of_players
    @current_marble_id = 0
    @current_marble = Marble.new(@current_marble_id, nil, nil)
    @current_player = 0
    @player_scores = Array.new(number_of_players, 0)
  end

  def play
    while @current_marble_id < @last_marble_id
      play_turn
    end

    pp @player_scores.each_with_index.map { |s, p| [p + 1, s] }.sort_by {|v| v[1]}.reverse[0][1]
  end

  def play_turn
    @current_player += 1
    @current_player = 1 if @current_player > @number_of_players
    new_marble_id = @current_marble_id + 1
    #puts "Current player #{@current_player}, marble #{new_marble_id}."

    raise 'No more turns!' if new_marble_id > @last_marble_id

    if new_marble_id % 23 == 0
      # Add current marble id to player score
      @player_scores[@current_player - 1] += new_marble_id

      # Look for marble seven steps counterclockwise
      marble = @current_marble
      7.times do
        marble = marble.counterclockwise_marble
      end

      # Add this marble id also to the score
      @player_scores[@current_player - 1] += marble.id

      # New current marble is clockwise side
      @current_marble = marble.clockwise_marble
      @current_marble_id = new_marble_id

      # Update marble refs by calling delete
      marble.delete
      return
    end

    @current_marble = Marble.new(new_marble_id, @current_marble.clockwise_marble.clockwise_marble, @current_marble.clockwise_marble)
    @current_marble_id = new_marble_id
  end
end

class Marble
  attr_accessor :clockwise_marble
  attr_accessor :counterclockwise_marble

  def initialize(id, clockwise_marble, counterclockwise_marble)
    @id = id

    if clockwise_marble.nil?
      @clockwise_marble = self
    else
      @clockwise_marble = clockwise_marble
      clockwise_marble.counterclockwise_marble = self
    end

    if counterclockwise_marble.nil?
      @counterclockwise_marble = self
    else
      @counterclockwise_marble = counterclockwise_marble
      counterclockwise_marble.clockwise_marble = self
    end
  end

  def delete
    @clockwise_marble.counterclockwise_marble = @counterclockwise_marble
    @counterclockwise_marble.clockwise_marble = @clockwise_marble
  end

  def id
    @id
  end

  def to_s
    puts "Marble #{@id}, clockwise_marble #{@clockwise_marble.id}, counterclockwise_marble #{@counterclockwise_marble.id}"
  end
end

game = MarbleGame.new(7090100, 429)
game.play
