require 'active_support/all'
require 'pry-byebug'

class Universe
  attr_accessor :input, :observation_2d, :map, :observation_size, :map_size, :x_size, :y_size, :galaxies, :galaxy_pair_distances_hash
  def initialize
    @input = File.read('day_11_input.txt').lines.map(&:chomp)
    @observation_size = input.first.length
    @observation_2d = Array.new(observation_size){Array.new(observation_size)}
    init_observation_map
    @y_size = 0
    @x_size = 0
    @map = nil
    expand_observation_map
    set_map_from_expanded
    visualize_map
    @galaxies = []
    get_galaxies
    @galaxy_pair_distances_hash = Hash.new.with_indifferent_access
  end

  def sum_shortest_path_between_galaxy_pairs
    sum = 0
    galaxies.each do |galaxy|
      galaxies.reject{|g| g == galaxy}.each do |second_galaxy|
        hash_key = [galaxy.coordinates, second_galaxy.coordinates].sort
        galaxy_pair_distances_hash[hash_key] = distance_between(first: galaxy, second: second_galaxy)
      end
    end
    galaxy_pair_distances_hash.keys.each do |pair|
      sum += galaxy_pair_distances_hash[pair]
    end
    puts galaxy_pair_distances_hash.values.reduce(:+)
  end

  def distance_between(first: , second:)
    (second.x - first.x).abs + (second.y - first.y).abs
  end

  def init_observation_map
    input.each_with_index do |line, row_index|
      line.each_char.with_index  do |character, column_index|
        @observation_2d[row_index][column_index] = Location.new(type: character, coords: [row_index, column_index] )
      end
    end
  end

  def expand_observation_map
    expand_columns # columns first so I can tranpose
    expand_rows
  end

  def expand_columns
    columns_to_insert = []
    transposed_map = observation_2d.transpose

    transposed_map.each_with_index do |column, column_index|
      columns_to_insert << column_index if column.all?{|location| location.empty_space? }
    end

    columns_to_insert.each_with_index do |column, index|
      @observation_2d.each_with_index do |row, row_index|
        @observation_2d[row_index] = row.insert(column+index, Location.new(type: ".", coords: [row_index, column+index]))
      end
    end

    @y_size = observation_2d.first.size
  end

  def expand_rows
    rows_to_insert = []
    @observation_2d.each_with_index do |row, row_index|
      rows_to_insert << row_index if row.all?{|location| location.empty_space?}
    end
    rows_to_insert.each_with_index do |r, index|
      observation_2d.insert(r+index, Array.new(y_size))
    end
    @observation_2d.each_with_index do |row, row_index|
      row.each_with_index do |column, column_index|
        location = observation_2d[row_index][column_index]
        @observation_2d[row_index][column_index] = Location.new(type: ".", coords: [0,0]) if location.nil?
      end
    end
    @x_size = observation_2d.size
  end

  def set_map_from_expanded
    @map = Array.new(x_size){Array.new(y_size)}
    @observation_2d.each_with_index do |row, x|
      row.each_with_index do |location, y|
        @map[x][y] = Location.new(type: location.type, coords: [x,y])
      end
    end
  end

  def visualize_map
    @map.each_with_index do |line, x|
      row_string = ''
      line.each_with_index  do |location, y|
        row_string << '#' if location.galaxy?
        row_string << '.' if location.empty_space?
      end
      puts row_string
    end
  end

  def get_galaxies
    @observation_2d.each_with_index do |row, x|
      row.each_with_index do |location, y|
        @galaxies << @map[x][y] if @map[x][y].galaxy?
      end
    end
  end

  class Location
    attr_accessor :coordinates, :type, :x, :y
    def initialize(type: ,coords:)
      @type = type
      @coordinates = coords
      @x = coordinates.first
      @y = coordinates.last
    end

    def empty_space?
      type == "."
    end

    def galaxy?
      type == "#"
    end
  end
end

Universe.new.sum_shortest_path_between_galaxy_pairs
