require 'active_support/all'
require 'pry-byebug'

class Farmville
  attr_accessor :input, :seeds, :seed_locations, :seed_to_soil_map, :soil_to_fertilizer_map, :fertilizer_to_water_map, :water_to_light_map, :light_to_temperature_map, :temperature_to_humidity_map, :humidity_to_location_map

  def initialize
    @input = File.read('day_5_input.txt').lines.map(&:chomp)
    input_seeds = input.first.split(':').last.strip.split(' ')
    @seeds = Array.new(input_seeds).map(&:to_i)
    map_strings = ['seed-to-soil map:', 'soil-to-fertilizer map:', 'fertilizer-to-water map:', 'water-to-light map:', 'light-to-temperature map:', 'temperature-to-humidity map:', 'humidity-to-location map:']
    map_strings.each do |map|
      ivar = map.gsub(Regexp.union(' ','-'), '_').delete(':')
      instance_variable_set("@#{ivar}", build_map(map_string: map))
    end
    @seed_locations = {}
    find_seed_locations
  end

  def minimum_location
    puts "Part 1 answer: #{seed_locations.values.min}"
  end

  def find_seed_locations
    seeds.each do |seed|
      soil = find_next(value: seed, map: seed_to_soil_map)
      fertilizer = find_next(value: soil, map: soil_to_fertilizer_map)
      water = find_next(value: fertilizer, map: fertilizer_to_water_map)
      light = find_next(value: water, map: water_to_light_map)
      temperature = find_next(value: light,map: light_to_temperature_map)
      humidity = find_next(value: temperature, map: temperature_to_humidity_map)
      location = find_next(value: humidity, map: humidity_to_location_map)
      seed_locations[seed] = location
    end
  end

  def find_next(value: , map: )
    range = map.keys.select{|range| range.include?(value)}.first
    return value if range.nil?
    source = range.first
    destination = map[range]
    offset = value - source
    destination + offset
  end

  def build_map(map_string: )
    start_index, ending_index = find_start_and_end_index(map_string: map_string)
    build_range_map(start_index: start_index, ending_index: ending_index)
  end

  def find_start_and_end_index(map_string: )
    start_index = 0
    data_lines = 0
    input.each_with_index do |line, index|
      start_index = index + 1 if line.include?(map_string)
    end
    input[start_index..-1].each_with_index do |line, index|
      data_lines = index - 1
      break if line == ('')
    end
    ending_index = start_index + data_lines
    return start_index, ending_index
  end

  def build_range_map(start_index:, ending_index:)
    hash = Hash.new
    input[start_index..ending_index].each do |line|
      data = line.split(" ")
      source = data.second.to_i
      destination = data.first.to_i
      range = data.last.to_i
      hash[source...source+range] = destination
    end
    hash
  end
end

Farmville.new.minimum_location
