require 'active_support/all'

class Network
  attr_accessor :input, :instructions, :nodes, :current_position

  def initialize
    @input = File.read('day_8_input.txt').lines.map(&:chomp)
    @instructions = input.first
    @nodes = build_nodes
    @current_position = nodes.select{|node| node.start_location? }.first
  end

  def build_nodes
    nodes = []
    subs = Regexp.union('=','(', ')', ',')
    input[2..-1].each do |line|
      data = line.gsub(subs, '').split
      nodes << Node.new(position: data.first, turn_left: data.second, turn_right: data.last)
    end
    nodes
  end

  def turn(move: )
    nodes.select{|node| node.location == move}.first
  end

  def steps_to_exit
    steps_taken = 0
    until current_position.end_location?
      instructions.each_char do |char|
        position = @current_position
        new_position = char == 'L' ? turn(move: position.left) : turn(move: position.right)
        @current_position = new_position
        steps_taken += 1
        break if current_position.end_location?
      end
    end
    return steps_taken
  end

  class Node
    attr_accessor :location, :left, :right
    def initialize(position: , turn_left: , turn_right: )
      @location = position
      @left = turn_left
      @right = turn_right
    end

    def start_location?
      location == 'AAA'
    end

    def end_location?
      location == 'ZZZ'
    end
  end
end

puts Network.new.steps_to_exit
