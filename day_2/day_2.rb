require 'active_support/all'

class Games
  RED = 'red'
  GREEN = 'green'
  BLUE = 'blue'
  attr_accessor :games_input, :games

  def initialize
    @games_input = File.read('day_2_input.txt').lines.map(&:chomp)
    @games = []
    games_input.each do |game|
      games << Game.new(data: game)
    end
  end

  def sum_valid_game_ids
    games.select{|game| game.valid?}.collect{|game| game.id}.reduce(:+)
  end

  def power_sum
    games.collect{|game| game.power}.reduce(:+)
  end

  class Game
    attr_accessor :id, :data, :rounds
    def initialize(data: )
      @data = data
      @id = data.split(':').first.delete("^0-9").to_i
      @rounds = []
      data.split(':')[1].split(';').each do |round|
        init_values = round.split(',')
        red, green, blue = 0
        init_values.each do |value|
          red = value.delete("^0-9").to_i if value.include?(RED)
          green = value.delete("^0-9").to_i if value.include?(GREEN)
          blue = value.delete("^0-9").to_i if value.include?(BLUE)
        end
        rounds << Round.new(red: red, green: green, blue: blue)
      end
    end

    def valid?
      rounds.all?{|round| round.valid_round?}
    end

    def largest_red
      rounds.select{|round| round.red.present?}.max{ |a, b| a.red <=> b.red}.red
    end

    def largest_green
      rounds.select{|round| round.green.present?}.max{ |a, b| a.green <=> b.green}.green
    end

    def largest_blue
      rounds.select{|round| round.blue.present?}.max{ |a, b| a.blue <=> b.blue}.blue
    end

    def power
      largest_red * largest_green * largest_blue
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

end
