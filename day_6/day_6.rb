require 'active_support/all'

class BoatRaces
  attr_accessor :input, :races, :race_2

  def initialize
    @input = File.read('day_6_input.txt').lines.map(&:chomp)
    @races = init_races
    @race_2 = init_part_2
  end

  def init_races
    list = []
    times = input.first.split(':').last.split(' ')
    distances = input.last.split(':').last.split(' ')

    times.each_with_index do |time, index|
      list << Race.new(time: time, distance: distances[index])
    end
    list
  end

  def init_part_2
    time = input.first.split(':').last.delete("^0-9")
    distance = input.last.split(':').last.delete("^0-9")

    Race.new(time: time, distance: distance)
  end

  def calc_part_one
    puts races.map{|race| race.ways_to_win.count}.inject(:*)
  end

  def calc_part_two
    puts race_2.ways_to_win.count
  end

  class Race
    attr_accessor :time, :distance, :ways_to_win
    def initialize(time: , distance: )
      @time = time.to_i
      @distance = distance.to_i
      @ways_to_win = []
      calc_wins
    end

    def calc_wins
      time.times do |iteration|
        ways_to_win << iteration if win?(value: iteration)
      end
    end

    def win?(value: )
      distance_traveled(value: value) > distance
    end

    def distance_traveled(value: )
      traveled = 0
      hold_time = value
      travel_time = time - hold_time
      traveled = value * travel_time
      traveled
    end
  end
end

races = BoatRaces.new
races.calc_part_one
races.calc_part_two
