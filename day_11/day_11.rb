require 'active_support/all'
require 'pry-byebug'

class Universe
  attr_accessor :input, :observation_2d, :observation_size, :galaxies, :galaxy_pair_distances_hash, :expansion_factor
  def initialize
    @input = File.read('day_11_input.txt').lines.map(&:chomp)
    @observation_size = input.first.length
    @observation_2d = Array.new(observation_size){Array.new(observation_size)}
    init_observation_map
    @expansion_factor = 999999
    expand_map_coords
    @galaxies = []
    get_galaxies
    @galaxy_pair_distances_hash = Hash.new.with_indifferent_access
  end

  def sum_shortest_path_between_galaxy_pairs
    galaxies.each do |galaxy|
      galaxies.reject{|g| g == galaxy}.each do |second_galaxy|
        hash_key = [galaxy.coordinates, second_galaxy.coordinates].sort
        galaxy_pair_distances_hash[hash_key] = distance_between(first: galaxy, second: second_galaxy)
      end
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

  def expand_map_coords
    empty_rows = []
    @observation_2d.each_with_index do |row, row_index|
      empty_rows << row_index if row.all?{|location| location.empty_space?}
    end

    empty_columns = []
    transposed_map = observation_2d.transpose
    transposed_map.each_with_index do |column, column_index|
      empty_columns << column_index if column.all?{|location| location.empty_space? }
    end

    empty_rows.each do |row|
      @observation_2d.slice(row..observation_size).each do |shift_row|
        shift_row.each do |location|
          location.coordinates = [location.x + expansion_factor, location.y]
        end
      end
    end

    empty_columns.each do |column|
      @observation_2d.each_with_index do |row, row_index|
        row.each_with_index do |location, column_index|
          location.coordinates = [location.x, location.y + expansion_factor] if column_index > column
        end
      end
    end

  end

  def get_galaxies
    @observation_2d.each_with_index do |row, x|
      row.each_with_index do |location, y|
        @galaxies << location if location.galaxy?
      end
    end
  end

  class Location
    attr_accessor :coordinates, :type
    def initialize(type: ,coords:)
      @type = type
      @coordinates = coords
    end

    def x
      coordinates.first
    end

    def y
      coordinates.last
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
