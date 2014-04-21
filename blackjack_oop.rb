class Card
  attr_accessor :suit, :rank

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = []

    ["Clubs", "Hearts", "Spades", "Diamonds"].each {|suit|
      ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"].each { |rank|
        cards << Card.new(suit, rank)
      }
    }
    shuffle
  end

  def shuffle
    cards.shuffle!
  end

  def deal_card(hand)
    dealt_card = cards.pop
    hand.add_card(dealt_card)
    dealt_card
  end
end

class Participant
  attr_accessor :name
  attr_reader :cards

  def initialize name
    @cards = []
    @name = name
  end

  def add_card card
    cards << card
  end

  def hand_value
    (sum_cards(11) > 21) ? sum_cards(1) : sum_cards(11)
  end

  def print_value
    "#{name}'s hand value: #{hand_value}"
  end

  def hit_or_stay
    # No-op for this class; to be implemented in derived class
  end

  def sum_cards(ace_value)
    sum = 0
    cards.each { |card|
      val = card.rank.to_i
      if val == 0
        val = (card.rank == "Ace" ? ace_value : 10)
      end
      sum += val
    }
    sum
  end

  def to_s
    ret = "#{name}'s hand: "
    cards.each { |card|
      ret += "#{card}, "
    }
    ret.slice!(-2..-1)
    ret
  end
end

class Player < Participant
  def hit_or_stay deck
    puts "=> Do you want to (h)it or (s)tay?"
    cmd = gets.chomp.downcase
    case cmd
    when 'h'
      new_card = deck.deal_card(self)
      puts "#{name} hits and is dealt the #{new_card}."
    when 's'
      puts "#{name} stays."
    else
      puts "Try again..."
      hit_or_stay deck
    end
  end
end

class Dealer < Participant
  def hit_or_stay deck
    val = hand_value
    case val
    when 1..16
      new_card = deck.deal_card(self)
      puts "#{name} hits and is dealt the #{new_card}."
    else
      puts "#{name} stays."
    end
  end
end

# TEST CODE
new_deck = Deck.new
player = Player.new("Russ")
dealer = Dealer.new("Sammy")
2.times do
  new_deck.deal_card(player)
  new_deck.deal_card(dealer)
end

puts "#{player}"
puts player.print_value
player.hit_or_stay new_deck
puts "#{player}"
puts player.print_value
puts ''
puts "#{dealer}"
puts dealer.print_value
dealer.hit_or_stay new_deck
puts "#{dealer}"
puts dealer.print_value
