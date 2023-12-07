require 'active_support/all'

class Calibration
  attr_accessor :calibration_array

  def initialize
    @calibration_array = File.read('problem_1_input.txt').lines.map(&:chomp)
  end

  # On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.
  def calibration_value(line: )
    cleaned_line = line.delete("^0-9")
    first_digit = cleaned_line.first
    second_digit = cleaned_line.last
    "#{first_digit}#{second_digit}".to_i
  end

  def replace_pseudo_values(line: )
    substitutions = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9}.with_indifferent_access
    regex = Regexp.union(substitutions.keys)
    converted_line = line.gsub(regex, substitutions)
    calibration_value(line: converted_line)
  end

  def calculate
    calibration_array.map{|line| calibration_value(line: line) }.reduce(:+)
  end

  # spelled out with letters: one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".
  def calculate_using_pseudo_digits
    calibration_array.map{|line| replace_pseudo_values(line: line) }.reduce(:+)
  end
end
