# Find the single giant loop starting at S. How many steps along the loop does it take to get from the starting position to the point farthest from the starting position?
require 'active_support/all'
require 'pry-byebug'

class Maze
  attr_accessor :input, :size, :locations_2d, :starting_location, :loop, :current_location, :loop_length
  def initialize
    @input = File.read('day_10_input.txt').lines.map(&:chomp)
    @size = input.first.length
    @locations_2d = Array.new(size){Array.new(size)}
    init_locations
    @starting_location = find_start_location
    build_connections
    get_starting_connections
    @loop_length = walk_loop
  end

  def farthest_point
    puts (BigDecimal(loop_length) / BigDecimal(2)).round
  end

  def init_locations
    input.each_with_index do |line, row_index|
      line.each_char.with_index  do |character, column_index|
        locations_2d[row_index][column_index] = Location.new(type: character, position: [row_index,column_index])
      end
    end
  end

  def find_start_location
    input.each_with_index do |line, row_index|
      line.each_char.with_index  do |character, column_index|
        return locations_2d[row_index][column_index] if locations_2d[row_index][column_index].start?
      end
    end
  end

  def get_starting_connections
    input.each_with_index do |line, row_index|
      line.each_char.with_index  do |character, column_index|
        location = locations_2d[row_index][column_index]
        starting_location.connections << location if location.connections.include?(starting_location)
      end
    end
  end

  def build_connections
    input.each_with_index do |line, row_index|
      line.each_char.with_index  do |character, column_index|
        this_location = locations_2d[row_index][column_index]
        next if this_location.ground? || this_location.start?

        connection_offsets = Location::CONNECTS[this_location.type]
        connection_offsets.each do |offset|
          new_x = this_location.x + offset.first
          new_y = this_location.y + offset.second
          last_row = size - 1
          next if new_x > last_row || new_x < 0
          next if new_y > last_row || new_y < 0
          new_location = locations_2d[new_x][new_y]
          this_location.connections << new_location if new_location.pipe? && !this_location.connections.include?(new_location)
        end
      end
    end
  end

  def walk_loop
    starting_location.walked = true
    steps = 0
    current_location = starting_location
    while true
      walk_to = current_location.connections.select{|loc| loc.not_walked?}.first
      break if walk_to.nil?
      steps += 1
      current_location = walk_to
      current_location.walked = true
    end
    return steps
  end

  class Location
    attr_accessor :type, :coordinates, :x, :y, :connections, :walked
    def initialize(type: , position:  )
      @type = type
      @coordinates = position
      @connections = []
      @x = coordinates.first
      @y = coordinates.second
      @walked = false
    end

    CONNECTS = {
      '|': [ [-1,0], [1,0] ],
      '-': [ [0,-1], [0,1] ],
      'L': [ [-1,0], [0,1] ],
      'J': [ [-1,0], [0,-1] ],
      '7': [ [0,-1], [1,0] ],
      'F': [ [0,1], [1,0] ]
    }.with_indifferent_access

    def start?
      type == 'S'
    end

    def ground?
      type == '.'
    end

    def pipe?
      !ground?
    end

    def fully_connected?
      connections.count == 2
    end

    def walked?
      walked == true
    end

    def not_walked?
      !walked?
    end

  end
end

Maze.new.farthest_point
