require 'active_support/all'
require 'pry-byebug'

class Network
  attr_accessor :input, :instructions, :nodes, :current_position, :ghosts, :first_end_locations, :second_end_locations

  def initialize
    @input = File.read('day_8_input.txt').lines.map(&:chomp)
    @instructions = input.first
    @nodes = build_nodes
    @current_position = nodes.select{|node| node.start_location? }.first
    @ghosts =  nodes.select{|node| node.start_location? }
    @first_end_locations = {}
    @second_end_locations = {}
    @steps = 0
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

  def ghost_walk
    until second_end_locations.keys.count == 6 && second_end_locations.keys.all?{ |location| (@second_end_locations[location] % @first_end_locations[location]) == 0}
      instructions.each_char do |char|
        new_nodes = @ghosts.map{|node| char == 'L' ? turn(move: node.left) : turn(move: node.right) }
        @steps += 1
        @ghosts = new_nodes
        new_nodes.each do |node|
          @second_end_locations[node] = @steps if node.end_location? && @first_end_locations.keys.include?(node) && !@second_end_locations.keys.include?(node)
          @first_end_locations[node] = @steps if node.end_location? && !@first_end_locations.keys.include?(node)
        end
        break if @second_end_locations.keys.count == 6 && second_end_locations.keys.all?{ |location| (@second_end_locations[location] % @first_end_locations[location]) == 0}
      end
    end
    puts @first_end_locations.values.reduce(1, :lcm)
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
      location.last == 'A'
    end

    def end_location?
      location.last == 'Z'
    end
  end
end

Network.new.ghost_walk
