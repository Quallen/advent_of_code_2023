require 'active_support/all'
require 'rspec'

class CamelCards
  attr_accessor :input, :hands, :sorted_hands, :bucket_keys

  def initialize
    @input = File.read('day_7_input.txt').lines.map(&:chomp)
    @hands = []
    @bucket_keys = [:five_of_a_kind, :four_of_a_kind, :full_house, :three_of_a_kind, :two_pair, :one_pair, :high_card]
    get_hands
    @sorted_hands = Hash.new
    @current_rank = 1
    put_hands_in_buckets
    sort_buckets
    rank_hands
  end

  def score_game
    puts hands.map{|hand| hand.rank * hand.bid}.reduce(:+)
  end

  def get_hands
    input.each do |line|
      hands << Hand.new(cards_string: line.split(' ').first, bid: line.split(' ').last)
    end
  end

  def sort_buckets
    bucket_keys.each do |key|
      sorted = sorted_hands[key].sort_by{|hand| [hand.cards.first.strength, hand.cards.second.strength , hand.cards.third.strength, hand.cards.fourth.strength, hand.cards.last.strength]}
      sorted_hands[key] = sorted
    end
  end

  def rank_hands
    bucket_keys.reverse.each do |key|
      hands = sorted_hands[key]
      hands.each do |hand|
        this_rank = @current_rank
        hand.rank = this_rank
        @current_rank += 1
      end
    end
  end

  def put_hands_in_buckets
    bucket_keys.each do |key|
      sorted_hands[key] = []
    end

    hands.each do |hand|
      bucket_keys.each do |key|
        sorted_hands[key] << hand and break if hand.send("#{key.to_s}?")
      end
    end
  end

  class Hand
    attr_accessor :cards, :card_strengths, :card_values, :rank, :bid
    def initialize(cards_string: , bid:)
      @card_values = %w(A K Q T 9 8 7 6 5 4 3 2 J)
      @card_strengths = card_strengths_hash
      @cards = build_cards(cards_string: cards_string)
      @bid = bid.to_i
      @rank = 0
    end

    def build_cards(cards_string:)
      cards_list = []
      cards_string.chars.each do |card|
        cards_list << Card.new(card_face: card, card_strength: card_strengths[card])
      end
      cards_list
    end

    def card_strengths_hash
      hash = {}
      card_values.reverse.each_with_index do |card,index|
        hash[card] = index
      end
      hash
    end

    def five_of_a_kind?
      joker_count = cards.select{|card| card.text == 'J'}.count
      target = 5 - joker_count
      card_values.each do |value|
        return true if cards.select{|card| card.text == value}.count == target
      end
      false
    end

    def four_of_a_kind?
      joker_count = cards.select{|card| card.text == 'J'}.count
      target = 4 - joker_count
      card_values.each do |value|
        return true if cards.reject{|card| card.text == 'J'}.select{|card| card.text == value}.count == target
      end
      false
    end

    def full_house?
      joker_count = cards.select{|card| card.text == 'J'}.count
      target = 3 - joker_count
      card_values.reject{|value| value == 'J'}.each do |value|
        two_cards, three_cards = nil, nil
        three_cards = value if cards.reject{|card| card.text == 'J'}.select{|card| card.text == value}.count == target
        if three_cards
          card_values.each do |c_val|
            two_cards = c_val if ( cards.reject{|card| card.text == three_cards || card.text == 'J'}.select{|card| card.text == c_val}.count == 2 )
          end
        end
        return true if three_cards && two_cards
      end
      false
    end

    def three_of_a_kind?
      joker_count = cards.select{|card| card.text == 'J'}.count
      target = 3 - joker_count
      card_values.each do |value|
        return true if cards.select{|card| card.text == value}.count == target
      end
      false
    end

    def two_pair?
      # at this point joker hands only have a single joker and there are no pairs because pairs + joker moved up already
      joker_count = cards.select{|card| card.text == 'J'}.count
      target = 2 - joker_count
      first_pair, second_pair = nil, nil

      card_values.reject{|value| value == 'J'}.each do |value|
        first_pair = value if cards.select{|card| card.text == value}.count == target
        if first_pair
          card_values.each do |c_val|
            second_pair = c_val if ( cards.reject{|card| card.text == first_pair}.select{|card| card.text == c_val}.count == 2 ) && first_pair != second_pair
          end
        end
        return true if first_pair && second_pair
      end
      false
    end

    def one_pair?
      joker_count = cards.select{|card| card.text == 'J'}.count
      target = 2 - joker_count
      card_values.each do |value|
        return true if cards.select{|card| card.text == value}.count == target
      end
      false
    end

    def high_card?
      card_values.each do |value|
        return true if cards.select{|card| card.text == value}.count == 1
      end
      false
    end
  end

  class Card
    attr_accessor :input, :text, :strength
    def initialize(card_face: , card_strength:)
      @text = card_face
      @strength = card_strength
    end
  end
end

CamelCards.new.score_game
