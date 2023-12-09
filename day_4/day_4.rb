require 'active_support/all'

class Scratchcards

  attr_accessor :scratchcards, :cards

  def initialize
    @scratchcards = File.read('day_4_input.txt').lines.map(&:chomp)
    @cards = []
    initialize_cards
  end

  # Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  def initialize_cards
    scratchcards.each do |card|
      card = card.split(':')
      id = card.first.delete("^0-9").to_i
      all_numbers = card.last.split('|')
      winning_numbers = all_numbers.first.split(' ').map(&:to_i)
      numbers = all_numbers.last.split(' ').map(&:to_i)
      cards << Card.new(id: id, winning_numbers: winning_numbers, numbers: numbers)
    end
  end

  def total_points
    cards.map{|card| card.value}.reduce(:+)
  end

  class Card
    attr_accessor :id, :winning_numbers, :numbers
    def initialize(id:, winning_numbers:, numbers: )
      @id = id
      @winning_numbers = winning_numbers
      @numbers = numbers
    end

    def number_of_matches
      numbers.select{ |number| winning_numbers.include?(number)}.length
    end

    def value
      case number_of_matches
      when 0
        return 0
      when 1
        return 1
      else
        return 2.pow(number_of_matches - 1)
      end
    end
  end
end
