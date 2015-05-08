# Solver requires a board and dictionary
# Board can take unlimited string arguments but currently most methods are hardcoded to support 16
# Dictionary requires a text file with words and currently takes a word.txt file
# if you have any questions you can email me at richardlau.rlau@gmail.com

require 'set'
require 'benchmark'

class Board
  attr_accessor :grid

  def initialize(*letters)
    set_grid(letters)
    set_neighbors
  end

  private

  def set_grid(letters)
    letters = letters.each_slice(4)

    self.grid = letters.map do |row|
      row.map { |letter| Letter.new(letter) }
    end
  end

  def set_neighbors
    grid.each_with_index do |row, row_index|
      row.each_with_index do |letter, col_index|
        letter.neighbors << grid[row_index - 1][col_index - 1] unless row_index == 0 || col_index == 0 # up left
        letter.neighbors << grid[row_index - 1][col_index]   unless row_index == 0 # up
        letter.neighbors << grid[row_index - 1][col_index + 1] unless row_index == 0 || col_index == grid.first.size - 1 # up right
        letter.neighbors << grid[row_index][col_index + 1]   unless col_index == grid.first.size - 1 # right
        letter.neighbors << grid[row_index + 1][col_index + 1] unless row_index == grid.size - 1 || col_index == grid.first.size - 1 # down right
        letter.neighbors << grid[row_index + 1][col_index]   unless row_index == grid.size - 1 # down
        letter.neighbors << grid[row_index + 1][col_index - 1] unless row_index == grid.size - 1 || col_index == 0 # down left
        letter.neighbors << grid[row_index][col_index - 1]   unless col_index == 0 # left
      end
    end
  end
end

class Letter
  attr_reader :name, :neighbors
  attr_accessor :used

  def initialize(name)
    @name = name
    @neighbors = []
    @used = false
  end

  def unused_neighbors
    neighbors.select { |neighbor| neighbor.used == false }
  end
end

class Solver
  attr_reader :board, :results, :dictionary

  def initialize(board, dictionary)
    @board = board
    @results = Set.new
    @dictionary = dictionary
  end

  def search_board
    letters = board.grid.flatten!

    dictionary.words.each do |word|
      res = match_word(word, '', letters)
      results << res if res
    end
  end

  private

  def match_word(word, prefix, letters)
    return word if prefix == word
    letters.each do |letter|
      if word[prefix.size] == letter.name
        letter.used = true
        is_word = match_word(word, prefix + letter.name, letter.unused_neighbors)
        letter.used = false
        return is_word if is_word
      end
    end
    return nil
  end
end

class Dictionary
  attr_accessor :words

  def initialize(dictionary)
    self.words = Set.new
    File.foreach(dictionary) do |line|
      self.words << line.downcase.chomp unless (line.length < 4 || line.length > 16) #hardcoded max word length
    end
  end
end

solver = Solver.new(Board.new("b", "g", "e", "f","i", "h", "c", "o", "n", "a", "t", "m", "y", "p", "p", "u"), Dictionary.new('words.txt'))

puts Benchmark.measure { solver.search_board }
