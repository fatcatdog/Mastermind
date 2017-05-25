
class Code
  attr_reader :pegs
  PEGS = {
    red:    "r",
    orange: "o",
    yellow: "y",
    green:  "g",
    blue:   "b",
    purple: "p",
  }

  def self.parse(colors)
    colors = colors.downcase.split("")
    raise unless colors.all? { |color| PEGS.values.include?(color) }

    Code.new(colors)
  end

  def self.random(number_of_pegs = nil)
    colors = []

    number_of_pegs = rand(4..7) unless number_of_pegs
    number_of_pegs.times { colors << PEGS.values.sample }

    Code.new(colors)
  end

  def initialize(pegs)
    @pegs = pegs
  end

  def [](index)
    @pegs[index]
  end

  def exact_matches(test_code)
    matches = 0

    @pegs.each_index { |peg| matches += 1 if self[peg] == test_code[peg] }

    matches
  end

  def near_matches(test_code)
    near_matches = 0
    color_counts = {secret_code: {}, guessed_code: {}}

    guess_pegs = test_code.pegs
    PEGS.each_value do |color|
      color_counts[:secret_code][color] =
        @pegs.select { |peg| peg == color }.count
      color_counts[:guessed_code][color] =
        guess_pegs.select { |peg| peg == color }.count
    end

    color_counts[:secret_code].each do |color, count|
      if (count > 0) && (color_counts[:guessed_code][color] > 0)
        if count < color_counts[:guessed_code][color]
          near_matches += count
        else
          near_matches += color_counts[:guessed_code][color]
        end
      end
    end

    near_matches - exact_matches(test_code)
  end

  def ==(code)
    code.is_a?(Code) && code.pegs == @pegs
  end
end


class Game
  attr_reader :secret_code, :current_guess, :guesses, :name

  def initialize(user_input = "")
    @guesses = 0

    case user_input
    when String
      @name = user_input
      @secret_code = Code.random
    when Code
      @secret_code = user_input
    else
      raise
    end
  end

  def play
    welcome_message

    get_guess
    take_turn until won? || lost? || quit?

    winning_message if won?
    losing_message if lost?
    puts %(\nUser ended game!) if quit?
  end

  def welcome_message
    print "\nWelcome, #{name}... "
    help_message
    puts "\n**This secret code is #{@secret_code.pegs.count} pegs long**"
  end

  def help_message
    puts %(You have ten tries to guess my secret code!)
    puts %(\nColor choices are:
 "r"ed "o"range "y"ellow "g"reen "b"lue and "p"urple.)
    puts %(\nEnter your guess as i.e. "roygbp" for a six-peg code.)
    puts %(Enter "h" for help or "q" to quit at any time.)
  end

  def get_guess
    puts "\nAttempt \##{@guesses + 1}"
    print "Guess the secret code: "
    guess = gets.chomp

    case guess
    when "h"
      help
      @current_guess = "h"
    when "q"
      @current_guess = "q"
    else
      @current_guess = Code.new(guess.split(""))
    end
  end

  def help
    print %(\n)
    67.times {print "-"}
    print %(\n)

    puts %(Mastermind HELP)
    help_message

    67.times {print "-"}
    print %(\n)
  end

  def take_turn
    if @current_guess.is_a?(Code)
      display_matches(@current_guess)
      @guesses += 1
    end

    get_guess unless lost? || quit?
  end

  def display_matches(code)
    puts %(Found #{@secret_code.exact_matches(code)} exact matches)
    puts %(Found #{@secret_code.near_matches(code)} near matches)
  end

  def won?
    @current_guess == @secret_code
  end

  def lost?
    @guesses == 10
  end

  def quit?
    @current_guess == "q"
  end

  def winning_message
    puts %(\nCongratulations! You guessed the secret code "#{@secret_code.pegs.join("")}" correctly in #{guesses + 1} tries!)
  end

  def losing_message
    puts %(\nOh no! Out of guesses, you lose!)
    puts %(My secret code was "#{@secret_code.pegs.join("")}".)
  end
end


########################################################
if __FILE__ == $PROGRAM_NAME
  game_name, game_class = "Mastermind", Game

  require_relative '../../../../Lizzi_extras/game_wrapper.rb'
  GameWrapper.new(game_name, game_class).run
end
########################################################
