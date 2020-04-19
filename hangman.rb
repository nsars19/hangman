# TODO
# -Serialization
# --save option at end of turn
# --load option at beginning of game
require 'json'

class Board
  # Remove newline & carriage return chars. from each word
  @@word_list = File.open('words.txt', 'r').map do |word|
    word = word[0..-3]
  end.filter { |word| word.size >= 5 && word.size <= 12 }

  def initialize
    @word            = get_random_word
    @guesses_left    = 6
    @letters_guessed = []
    @board           = []
    create_board
  end

  def game_start
    puts "Type 'play' to start a new game, or type 'load' to load a saved game."
    start_choice = gets.chomp
    show_saved_games if start_choice == 'load'
    play_game        if start_choice == 'play'
  end
  
  private
  def play_game
    puts "Type a letter to start playing hangman! or type 'save' to save and exit mid-game."
    until game_over?
      make_guess gets.strip
      display_board
    end
    puts "#{@word} was the secret word."
  end

  def show_saved_games
    puts Dir.entries "./saves"

  end

  def save_and_exit
    Dir.mkdir('saves') unless Dir.exists?('saves')

    vars_to_save = {
      :board           => @board,
      :guesses_left    => @guesses_left,
      :word            => @word,
      :letters_guessed => @letters_guessed
    }

    time = Time.new.strftime("%m%d%Y_%k%M%S")
    filename = "./saves/#{time}.json"

    File.open(filename, 'w') do |file|
      file.puts vars_to_save.to_json
    end

    exit
  end
  def make_guess guess
    save_and_exit if guess == 'save'
    until !@letters_guessed.include?(guess) && guess.length == 1
      puts "Please select a single letter that you have not already chosen:"
      guess = gets.chomp
    end

    @letters_guessed << guess
    check_guess guess
  end

  def display_board
    a, b, c = @board.join(" "), @guesses_left, @letters_guessed.join(" ")
    puts "#{a} | guesses left: #{b} | letters guessed: #{c}"
  end 

  def check_guess guess
    update_board(guess) if @word.include? guess
    @guesses_left -= 1 if !@word.include? guess
  end

  def update_board letter_chosen
    @word.split('').each_with_index do |e, i|
      @board[i] = letter_chosen if e == letter_chosen
    end
  end

  def create_board
    board_size = @word.length
    board_size.times { |i| @board << '_' }
  end

  def get_random_word
    @@word_list[rand(@@word_list.size)].downcase
  end

  def win?
    return true if @board.join == @word; false
  end

  def lose?
    return true if @guesses_left == 0; false
  end

  def game_over?
    win? || lose? ? true : false
  end
end

Board.new.game_start