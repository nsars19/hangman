class Board
  # Remove newline & carriage return chars. from each word
  @@word_list = File.open('words.txt', 'r').map do |word|
    word = word[0..-3]
  end.filter { |word| word.size >= 5 && word.size <= 12 }

end
