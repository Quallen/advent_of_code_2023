require 'rspec'
require_relative '../day_7'

RSpec.describe "Hand" do
  describe "type predicates" do
    describe "#full_house?" do
      context "3 fives and 2 Aces" do
        it "returns true" do
          string = "AA555 123"
          hand = CamelCards::Hand.new(cards_string: string.split(' ').first, bid: string.split(' ').last)
          expect(hand.full_house?).to eq true
        end
      end
      context "2 fives and 3 Aces" do
        it "returns true" do
          string = "AAA55 123"
          hand = CamelCards::Hand.new(cards_string: string.split(' ').first, bid: string.split(' ').last)
          expect(hand.full_house?).to eq true
        end
      end
      context "2 pair and a jack" do
        it "returns true" do
          string = "JAA55 123"
          hand = CamelCards::Hand.new(cards_string: string.split(' ').first, bid: string.split(' ').last)
          expect(hand.full_house?).to eq true
        end
      end
    end
  end
end
