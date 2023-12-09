require 'active_support/all'

class Schematic
  attr_accessor :schematic, :array_2d, :symbol_coordinates, :part_numbers, :digit_regex, :length, :gears

  def initialize
    @schematic = File.read('day_3_input.txt').lines.map(&:chomp)
    @array_2d = Array.new(141){Array.new(140)}
    @length = 140
    @symbol_coordinates = []
    @part_numbers = []
    @gears = []
    @digit_regex = /[\d]/
    schematic.each_with_index do | line, row_index |
      line.each_char.with_index do |character, column_index|
        array_2d[row_index][column_index] = character
      end
    end
    pad_array_bottom
    get_symbol_coordinates
    get_parts
    get_gears
  end

  def pad_array_bottom
    length.times do |x|
      array_2d[140][x] = '.'
    end
  end

  def sum_part_numbers
    part_numbers.flatten.reduce(:+)
  end

  def sum_gear_ratios
    gears.flatten.reduce(:+)
  end

  def find_part_number(x:, y:)
    part_number = ''
    while array_2d[x][y-1].present? && array_2d[x][y-1].match?(digit_regex)
      y = y-1
    end
    left_x = x
    left_y = y
    part_number << array_2d[left_x][left_y]
    while array_2d[x][y+1].present? && array_2d[x][y+1].match?(digit_regex)
      part_number << array_2d[x][y+1]
      y = y + 1
    end
    part_number
  end

  def get_parts
    symbol_coordinates.each do |coordinate|
      scan_for_parts(x: coordinate[0], y: coordinate[1])
    end
  end

  def get_gears
    symbol_coordinates.each do |coordinate|
      scan_for_gears(x: coordinate[0], y: coordinate[1])
    end
  end

  def scan_for_gears(x: , y:)
    gear_ratio_buffer = []
    gear_ratio_buffer << find_part_number(x: x, y: y-1) if array_2d[x][y-1].present? && array_2d[x][y-1].match?(digit_regex)
    gear_ratio_buffer << find_part_number(x: x, y: y+1) if array_2d[x][y+1].present? && array_2d[x][y+1].match?(digit_regex)
    gear_ratio_buffer << find_part_number(x: x-1, y: y) if array_2d[x-1][y].present? && array_2d[x-1][y].match?(digit_regex)
    gear_ratio_buffer << find_part_number(x: x-1, y: y-1) if array_2d[x-1][y-1].present? && array_2d[x-1][y-1].match?(digit_regex)
    gear_ratio_buffer << find_part_number(x: x-1, y: y+1) if array_2d[x-1][y+1].present? && array_2d[x-1][y+1].match?(digit_regex)
    gear_ratio_buffer << find_part_number(x: x+1, y: y) if array_2d[x+1][y].present? && array_2d[x+1][y].match?(digit_regex)
    gear_ratio_buffer << find_part_number(x: x+1, y: y-1) if array_2d[x+1][y-1].present? && array_2d[x+1][y-1].match?(digit_regex)
    gear_ratio_buffer << find_part_number(x: x+1, y: y+1) if array_2d[x+1][y+1].present? && array_2d[x+1][y+1].match?(digit_regex)
    gear_ratio_buffer = gear_ratio_buffer.uniq.map(&:to_i)
    if gear_ratio_buffer.count == 2
      gears << (gear_ratio_buffer.first * gear_ratio_buffer.last)
    end
  end

  def scan_for_parts(x: , y:)
    part_number_buffer = []
    part_number_buffer << find_part_number(x: x, y: y-1) if array_2d[x][y-1].present? && array_2d[x][y-1].match?(digit_regex)
    part_number_buffer << find_part_number(x: x, y: y+1) if array_2d[x][y+1].present? && array_2d[x][y+1].match?(digit_regex)
    part_number_buffer << find_part_number(x: x-1, y: y) if array_2d[x-1][y].present? && array_2d[x-1][y].match?(digit_regex)
    part_number_buffer << find_part_number(x: x-1, y: y-1) if array_2d[x-1][y-1].present? && array_2d[x-1][y-1].match?(digit_regex)
    part_number_buffer << find_part_number(x: x-1, y: y+1) if array_2d[x-1][y+1].present? && array_2d[x-1][y+1].match?(digit_regex)
    part_number_buffer << find_part_number(x: x+1, y: y) if array_2d[x+1][y].present? && array_2d[x+1][y].match?(digit_regex)
    part_number_buffer << find_part_number(x: x+1, y: y-1) if array_2d[x+1][y-1].present? && array_2d[x+1][y-1].match?(digit_regex)
    part_number_buffer << find_part_number(x: x+1, y: y+1) if array_2d[x+1][y+1].present? && array_2d[x+1][y+1].match?(digit_regex)
    part_numbers << part_number_buffer.uniq.map(&:to_i)
  end

  def get_symbol_coordinates
    regex = Regexp.union("!","@","#","$", "%","^","&","*","-", "+", "=", "/")

    length.times do |row_index|
      length.times do |column_index|
        symbol_coordinates << [row_index,column_index] if array_2d[row_index][column_index].match?(regex)
      end
    end
  end

end
