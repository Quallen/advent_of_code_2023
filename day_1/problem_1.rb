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
    # the trick here is string substitution solutions get wrecked by input like twone which if you sub the number for the pseudo number
    # gets you 2ne which calibrates to 22 when it should calibrate to 21. Trying to force people into find the index of the match and insert the number leaving the existing text alone
    # well i'm going to sub 2two for two so left pass on twone gives me 2twone and then last match gives me 2tw1one which then cleans to 21 after removing non digits
    # what I'm trying to say is Eric Wastl is a bad man
    substitutions = {'one': '1one', 'two': '2two', 'three': '3three', 'four': '4four', 'five': '5five', 'six': '6six', 'seven': '7seven', 'eight': '8eight', 'nine': '9nine'}.with_indifferent_access
    regex = Regexp.union(substitutions.keys)
    first_match_replaced = line.sub(regex, substitutions)
    last_match_regex = Regexp.union(/.*\K#{regex}/)
    last_match_replaced = first_match_replaced.gsub(last_match_regex, substitutions)
    calibration_value(line: last_match_replaced)
  end

  def calculate
    calibration_array.map{|line| calibration_value(line: line) }.reduce(:+)
  end

  # spelled out with letters: one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".
  def calculate_using_pseudo_digits
    calibration_array.map{|line| replace_pseudo_values(line: line) }.reduce(:+)
  end
end
