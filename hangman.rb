# TODO
# -Serialization
# --load option at beginning of game
require 'json'

class Board
  attr_writer :word, :guesses_left, :letters_guessed, :board

  # Remove newline & carriage return chars. from each word
  @@word_list = File.open('words.txt', 'r').map do |word|
    word = word[0..-3]
  end.filter { |word| word.size >= 5 && word.size <= 12 }

  def initialize loaded_game = false
    @loaded_game     = loaded_game
    @word            = get_random_word
    @guesses_left    = 6
    @letters_guessed = []
    @board           = []
    create_board    if @board.empty?
    game_start  unless @loaded_game
  end
  
  private
  def play_saved_game word, guesses_left, letters_guessed, board
    @letters_guessed = letters_guessed
    @guesses_left    = guesses_left
    @board           = board
    @word            = word
    
    display_board
    until game_over?
      make_guess gets.strip
      display_board
    end
  end

  def game_start
    puts "Type 'play' to start a new game, or type 'load' to load a saved game."
    start_choice = gets.chomp
    choose_save_game if start_choice == 'load'
    play_game        if start_choice == 'play'
  end
  
  def play_game
    puts "Type a letter to start playing hangman! or type 'save' to save and exit mid-game."
    until game_over?
      make_guess gets.strip
      display_board
    end
    puts "#{@word} was the secret word."
  end

  def choose_save_game
    saves = Dir.entries("./saves").filter {|e| e[-4..-1] == 'json' }
    saves.each { |e| puts e }
    puts "Select a save file to load. Type the first six digits to load a file."
    
    file_choice = gets.chomp
    saves.each { |e| load_game(e) if file_choice == e[0..5] }
  end

  def load_game file
    saved_game = File.open "./saves/#{file}"
    
    save = JSON.load(saved_game)
    play_saved_game save['word'], save['guesses_left'], save['letters_guessed'], save['board']
  end
  
  def save_and_exit
    Dir.mkdir('saves') unless Dir.exists?('saves')

    vars_to_save = {
      :board           => @board,
      :guesses_left    => @guesses_left,
      :word            => @word,
      :letters_guessed => @letters_guessed
    }

    time = Time.new.strftime("%k%M%S_%m%d%Y")
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
      save_and_exit if guess == 'save'
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

Board.new