require 'active_support/all'
require 'pry-byebug'

class Farmville
  attr_accessor :input, :seeds, :seed_locations, :seed_to_soil_map, :soil_to_fertilizer_map, :fertilizer_to_water_map, :water_to_light_map, :light_to_temperature_map, :temperature_to_humidity_map, :humidity_to_location_map, :seed_ranges

  def initialize
    raise ArgumentError.new "must pass in input file name" unless ARGV[0].present?
    raise ArgumentError.new "File not found" unless File.exist?(ARGV[0])
    @input = File.read(ARGV[0]).lines.map(&:chomp)
    input_seeds = input.first.split(':').last.strip.split(' ')
    @seeds = Array.new(input_seeds).map(&:to_i)
    map_strings = ['seed-to-soil map:', 'soil-to-fertilizer map:', 'fertilizer-to-water map:', 'water-to-light map:', 'light-to-temperature map:', 'temperature-to-humidity map:', 'humidity-to-location map:']
    map_strings.each do |map|
      ivar = map.gsub(Regexp.union(' ','-'), '_').delete(':')
      instance_variable_set("@#{ivar}", build_map(map_string: map))
    end
    @seed_locations = {}
    @seed_ranges = []
  end

  def minimum_location
    find_seed_locations
    puts "Part 1 answer: #{seed_locations.values.min}"
  end

  def init_seeds_from_ranges
    seeds.each_slice(2).to_a.each do |range|
      start_range = range.first
      end_range = start_range + range.second
      seed_ranges.append(start_range...end_range)
    end
  end

  def walk_it_back
    init_seeds_from_ranges
    lowest_seed_location = moonwalk_locations
    puts "Part 2 answer: #{lowest_seed_location}"
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

 def moonwalk_locations
   (1..seeds.max).each do |location|
     humidity = moonwalk(value: location, map: humidity_to_location_map)
     temperature = moonwalk(value: humidity,map: temperature_to_humidity_map)
     light = moonwalk(value: temperature, map: light_to_temperature_map)
     water = moonwalk(value: light, map: water_to_light_map)
     fertilizer = moonwalk(value: water, map: fertilizer_to_water_map)
     soil = moonwalk(value: fertilizer, map: soil_to_fertilizer_map)
     seed = moonwalk(value: soil, map: seed_to_soil_map)
     return location if seed_ranges.any?{ |range| range.include?(seed)}
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

  def moonwalk(value: , map:)
    end_range = map.values.select{|range| range.include?(value)}.first
    start_range = map.key(end_range)
    return value if end_range.nil?
    source = start_range.first
    destination = end_range.first
    offset = value - destination
    source + offset
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
      hash[source...source+range] = destination...destination+range
    end
    hash
  end
end

Farmville.new.walk_it_back
