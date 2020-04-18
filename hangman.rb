# TODO
# -Serialization
# --save option at end of turn
# --load option at beginning of game

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

  def play_game
    puts "Type a letter to start playing hangman!"
    until game_over?
      make_guess gets.strip
      display_board
    end
    puts "#{@word} was the secret word"
  end

  def make_guess guess
    until !@letters_guessed.include?(guess) && guess.length == 1
      puts "Please select a single letter that you have not already chosen:"
      guess = gets.chomp
    end

    @letters_guessed << guess
    check_guess guess
  end

  def display_board
    puts "#{@board.join(" ")} | guesses left: #{
            @guesses_left   } | letters guessed: #{
            @letters_guessed.join(" ")}"
  end

  private
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

Board.new.play_game