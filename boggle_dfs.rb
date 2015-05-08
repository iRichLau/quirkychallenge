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
    letters = letters * ""
    letters = letters.scan(/..../).map {|str| str.split ""}

    self.grid = letters.map do |row|
      row.map {|letter| Letter.new(letter)}
    end
  end

  def set_neighbors
    grid.each_with_index do |row, row_index|
      row.each_with_index do |letter, col_index|
        (-1..1).each do |row_offset|
          r = row_index + row_offset
          next unless (0...grid.size) === r
          (-1..1).each do |col_offset|
            next if row_offset == 0 && col_offset == 0
            c = col_index + col_offset
            next unless (0...grid.size) === c
            letter.neighbors << grid[r][c]
          end
        end
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

  MINIMUM_WORD_LENGTH = 3
  MAXIMUM_WORD_LENGTH = 16

  def initialize(board, dictionary)
    @board = board
    @results = Set.new
    @dictionary = dictionary
  end

  def search_board
    letters = board.grid.flatten!
    letters.each do |letter|
      make_words(letter)
    end
  end


  def make_words(letter, word="")
    letter.used = true
    word << letter.name

      if dictionary.is_a_word?(word)
        results << word unless (word.size < MINIMUM_WORD_LENGTH)
      end

    if (word.size >= MAXIMUM_WORD_LENGTH)
      letter.used = false
      return
    end

    letter.unused_neighbors.each do |unused|
      make_words(unused, word.dup)
    end

    letter.used = false
  end
end

class Dictionary
  attr_accessor :words

  def initialize(file)
    self.words = Set.new
    File.open(file, "r") do |file_handle|
      file_handle.each_line { |line| self.words << line.downcase.chomp unless (line.length < 3 || line.length > 16) }
    end
  end

  def is_a_word?(word)
    words.include?(word)
  end
end

solver = Solver.new(Board.new("b", "g", "e", "f","i", "h", "c", "o", "n", "a", "t", "m", "y", "p", "p", "u"), Dictionary.new('words.txt'))

puts Benchmark.measure { solver.search_board }
