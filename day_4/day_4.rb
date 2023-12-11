require 'active_support/all'

class Scratchcards

  attr_accessor :scratchcards, :cards, :cards_hash

  def initialize
    @scratchcards = File.read('day_4_input.txt').lines.map(&:chomp)
    @cards = []
    @cards_hash = {}
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

    cards.each do |card|
      cards_hash[card.id] = Array.new
      cards_hash[card.id] << MemoCard.new(id: card.id, number_of_matches: card.matches)
    end
  end

  def total_points
    cards.map{|card| card.value}.reduce(:+)
  end

  def run_game
    cards.each do |card|
      all_copies = cards_hash[card.id]
      id = card.id
      all_copies.each do |a_card|
        a_card.number_of_matches.times do |offset|
          new_id = id + 1 + offset
          new_card = cards_hash[new_id].first
          next if new_card.nil?
          cards_hash[new_id] << MemoCard.new(id: new_card.id, number_of_matches: new_card.number_of_matches)
        end
      end
    end
    cards.map{|card| cards_hash[card.id].count}.reduce(:+)
  end

  class Card
    attr_accessor :id, :winning_numbers, :numbers, :matches
    def initialize(id:, winning_numbers:, numbers: )
      @id = id
      @winning_numbers = winning_numbers
      @numbers = numbers
      @matches ||= number_of_matches
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

  class MemoCard
    attr_accessor :id, :number_of_matches
    def initialize(id:, number_of_matches: )
      @id = id
      @number_of_matches = number_of_matches
    end
  end
end

puts Scratchcards.new.run_game
