require 'active_support/all'

class ValidateGames
  RED = 'red'
  GREEN = 'green'
  BLUE = 'blue'
  attr_accessor :games_input

  def initialize
    @games_input = File.read('day_2_input.txt').lines.map(&:chomp)
  end

  class Game
    attr_accessor :game_id
    def initialize(data: )
      @data = data
      @game_id = data.split(':').first.delete("^0-9").to_i
    end
  end

  class Round
    MAX_RED = 12
    MAX_GREEN = 13
    MAX_BLUE = 14

    attr_accessor :red, :green, :blue

    def initialize(red: , green: , blue:)
      @red = red
      @green = green
      @blue = blue
    end

    def valid_round?
      red.to_i <= MAX_RED && green.to_i <= MAX_GREEN && blue.to_i <= MAX_BLUE
    end
  end

  def number_valid
    id_sum = 0
    games_input.each do |game|
      this_game = Game.new(data: game)
      rounds = game.split(':')[1].split(';')
      valid_game = true
      rounds.each do |round|
        init_values = round.split(',')
        red, green, blue = 0
        init_values.each do |value|
          red = value.delete("^0-9") if value.include?(RED)
          green = value.delete("^0-9") if value.include?(GREEN)
          blue = value.delete("^0-9") if value.include?(BLUE)
        end
        valid_game = false unless Round.new(red: red, green: green, blue: blue).valid_round?
      end
      id_sum += this_game.game_id if valid_game
    end
    id_sum
  end

  def power_sum
    power_sum = 0
    games_input.each do |game|
      this_game = Game.new(data: game)
      rounds = game.split(':')[1].split(';')
      red_seen, green_seen, blue_seen, power = 0,0,0,0
      rounds.each do |round|
        init_values = round.split(',')
        red, green, blue = 0,0,0
        init_values.each do |value|
          red = value.delete("^0-9").to_i if value.include?(RED)
          green = value.delete("^0-9").to_i if value.include?(GREEN)
          blue = value.delete("^0-9").to_i if value.include?(BLUE)
          red_seen = red if red.present? && red_seen < red
          green_seen = green if green.present? && green_seen < green
          blue_seen = blue if blue.present? && blue_seen < blue
        end
      end
      power_sum += (red_seen * green_seen * blue_seen)
    end
    power_sum
  end
end
