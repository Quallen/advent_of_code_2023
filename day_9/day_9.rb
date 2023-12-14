require 'active_support/all'
require 'pry-byebug'

class Report
  attr_accessor :input, :locations
  def initialize
    @input = File.read('day_9_input.txt').lines.map(&:chomp)
    @locations = []
    init_locations
  end

  def init_locations
    input.each do |line|
      @locations << Location.new(history: line.split(' ').map(&:to_i))
    end
  end

  def output_sum
    puts locations.map{ |location| location.extrapolate_next}.reduce(:+)
  end

  class Location
    attr_accessor :history, :steps, :increment
    def initialize(history: )
      @history = history
      @steps = []
      @increment = 0
      build_steps
    end

    def build_steps
      step_line = @history
      @steps << step_line

      until step_line.all?{|value| value.zero? }
        new_line = []
        step_line.each_with_index do |value, index|
          last_element_index = step_line.length - 1
          new_line and break if index >= last_element_index
          new_line[index] = step_line[index + 1] - value
        end
        @steps << new_line
        step_line = new_line
      end
    end

    def extrapolate_next
      old_to_new = @steps.reverse
      old_to_new.each_with_index do |array, index|
        break if index + 1 > old_to_new.count
        old_to_new[index] << array.last and next if array.uniq.count <= 1
        new_value = old_to_new[index].last + old_to_new[index-1].last
        old_to_new[index] << new_value
      end
      return @steps.first.last
    end
  end
end

Report.new.output_sum
