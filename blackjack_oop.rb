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

  def is_busted?
    if (hand_value > 21)
      puts "#{name} has busted!"
      return true
    else
      return false
    end
  end

  def print_value
    hand_value <= 21 ? "#{name}'s hand value: #{hand_value}" : "#{name}'s hand value: BUSTED!"
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
    cmd = prompt "=> Do you want to (h)it or (s)tay?  "
    cmd.downcase!
    case cmd
    when 'h'
      new_card = deck.deal_card(self)
      puts "#{name} hits and is dealt the #{new_card}."
      if is_busted?
        cmd = 'b'
      else
        puts print_value
      end
    when 's'
      puts "#{name} stays at #{hand_value}."
    else
      puts "Try again..."
      hit_or_stay deck
    end
    cmd
  end
end

class Dealer < Participant
  def hit_or_stay deck
    val = hand_value
    cmd = ''
    case val
    when 1..16
      new_card = deck.deal_card(self)
      puts "#{name} hits and is dealt the #{new_card}."
      if is_busted?
        cmd = 'b'
      else
        puts print_value
        cmd = 'h'
      end
    when 22..1000
      puts "#{name} has busted!"
      cmd = 'b'
    else
      puts "#{name} stays at #{hand_value}."
      cmd = 's'
    end
    cmd
  end
end

def prompt (str)
  print(str)
  gets.chomp
end

class Blackjack
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new("Player")
    @dealer = Dealer.new("Dealer")
  end

  def get_player_name
    player.name = prompt "=> What's your name? "
    player.name.capitalize!
  end

  def deal_cards
    puts "Shuffling and dealing cards..."
    2.times do
      deck.deal_card(player)
      deck.deal_card(dealer)
    end
  end

  def player_turn
    puts "\n#{player.name}'s turn..."
    puts "#{player}"
    puts player.print_value
    cmd = ''
    until cmd == 's' || cmd == 'b'
      cmd = player.hit_or_stay deck
    end
    cmd
  end

  def dealer_turn
    puts "\n#{dealer.name}'s turn..."
    puts "#{dealer}"
    puts dealer.print_value
    cmd = ''
    until cmd == 's' || cmd == 'b'
      cmd = dealer.hit_or_stay deck
    end
    cmd
  end

  def end_game(player_outcome, dealer_outcome)
    p_value = player.hand_value
    d_value = dealer.hand_value
    if p_value == 21
      puts "You hit BLACKJACK!"
    elsif d_value == 21
      puts "#{dealer.name} hit BLACKJACK!"
    else
      (p_value <= 21) ? (puts "\n#{player.print_value}  -  #{dealer.print_value}") : (puts '')
    end
    if player_outcome == 'b' || (p_value < d_value && dealer_outcome != 'b')
      puts "Better luck next time!"
    elsif dealer_outcome == 'b' || p_value > d_value
      puts "Congratulations, you win!"
    elsif p_value == d_value
      puts "Looks like it's a draw."
    end
  end

  def play
    get_player_name
    deal_cards
    p = player_turn
    if p != 'b' && player.hand_value != 21
      d = dealer_turn
    end
    end_game(p,d)
  end
end

game = Blackjack.new
game.play


