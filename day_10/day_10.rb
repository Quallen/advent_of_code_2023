# Find the single giant loop starting at S. How many steps along the loop does it take to get from the starting position to the point farthest from the starting position?
require 'active_support/all'
require 'pry-byebug'

class Maze
  attr_accessor :input, :size, :locations_2d, :starting_location, :loop, :current_location, :loop_length, :loop_locations, :enclosed_locations
  def initialize
    @input = File.read('day_10_input.txt').lines.map(&:chomp)
    @size = input.first.length
    @locations_2d = Array.new(size){Array.new(size)}
    @starting_location = nil
    init_locations
    build_connections
    get_starting_connections
    @loop_length = walk_loop
    @loop_locations = []
    @enclosed_locations = []
    get_loop_locations
    visualize_loop
    find_enclosed_locations
    visualize_enclosed_locations
  end

  def farthest_point
    puts (BigDecimal(loop_length) / BigDecimal(2)).round
  end

  def print_enclosed_locations_count
    puts enclosed_locations.count
  end

  def init_locations
    input.each_with_index do |line, row_index|
      line.each_char.with_index  do |character, column_index|
        locations_2d[row_index][column_index] = Location.new(type: character, position: [row_index,column_index])
        @starting_location = locations_2d[row_index][column_index] if locations_2d[row_index][column_index].start?
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

  def get_loop_locations
    input.each_with_index do |line, row_index|
      line.each_char.with_index  do |character, column_index|
        cell = locations_2d[row_index][column_index]
        loop_locations << cell if cell.walked? && !loop_locations.include?(cell)
      end
    end
  end

  def visualize_loop
    input.each_with_index do |line, x|
      row_string = ''
      line.each_char.with_index  do |character, y|
        cell = locations_2d[x][y]
        row_string << 'X' if cell&.walked?
        row_string << '.' if cell&.not_walked?
      end
      puts row_string
    end
  end

  def visualize_enclosed_locations
    puts "="*size
    input.each_with_index do |line, x|
      row_string = ''
      line.each_char.with_index  do |character, y|
        cell = locations_2d[x][y]
        row_string << '.' if cell.nil? || !enclosed_locations.include?(cell)
        row_string << 'X' if enclosed_locations.include?(cell)
      end
      puts row_string
    end
  end

  def find_enclosed_locations
    flip_flag_types = ['|', 'F', '7']
    input.each_with_index do |line, x|
      inside_flag = false
      line.each_char.with_index  do |character, y|
        cell = locations_2d[x][y]
        next if cell.nil?
        inside_flag = !inside_flag if flip_flag_types.include?(cell.type) && loop_locations.include?(cell)
        enclosed_locations << cell if cell.not_walked? && inside_flag
      end
    end
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

maze = Maze.new
maze.farthest_point
maze.print_enclosed_locations_count
