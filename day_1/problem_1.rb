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

  def calculate
    calibration_array.map{|line| calibration_value(line: line) }.reduce(:+)
  end
end
