class Code
  attr_reader :pegs

  PEGS = {
    "R" => :red,
    "O" => :orange,
    "Y" => :yellow,
    "G" => :green,
    "B" => :blue,
    "P" => :purple
   }

  def initialize(pegs)
     @pegs = pegs
  end

  def self.parse(code_string)
     chars = code_string.chars.map(&:upcase)
     pegs = chars.map { |char| PEGS[char]}
     self.new(pegs)
  end

  def self.random
    pegs = []
    4.times {pegs << PEGS.values.sample}
    self.new(pegs)
  end

  def [](idx)
    @pegs[idx]
  end

  def exact_matches(other)
    matches = 0
    4.times { |idx| matches += 1 if @pegs[idx] == other.pegs[idx]}
    matches
  end

  def near_matches(other)
    matches = 0
    PEGS.values.each do |color|
      matches += [@pegs.count(color), other.pegs.count(color)].min
    end
    matches - exact_matches(other)
  end


  def ==(other)
     return false unless other.class == Code
     @pegs == other.pegs
  end

  def to_s
    "[#{@pegs.join(", ")}]"
  end 

end

class Game
  attr_reader :secret_code

  def initialize(code = nil)
    @secret_code = code || Code.random
  end

  def get_guess
    puts "The possible colors are R, O, Y, G, B, P"
    print 'Enter a guess (ex. "BGPR"): '
    @guess = Code.parse(gets.chomp)
  end

  def display_matches
    puts "Near matches #{@secret_code.near_matches(@guess)}"
    puts "Exact matches #{@secret_code.exact_matches(@guess)}"
  end

def play
  10.times do |turn|
    get_guess
    break if won?
    display_matches
  end
  conclude
end

def won?
  @secret_code == @guess
end

def conclude
  if @guess == @secret_code
    puts "You won"
  else
    puts "You lose"
  end
  puts "The code was #{@secret_code}"
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new(Code.parse("brbr"))
  game.play
end
