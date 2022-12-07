# frozen_string_literal: true

class Board
  attr_accessor :squares

  FILES = ("a".."h").to_a
  RANKS = (1..8).to_a
  BLACK_FIRST_FILES = %w[a c e g]
  WHITE_FIRST_FILES = %w[b d f h]

  def initialize
    @squares = []
    create_board
  end

  def create_board
    coords = FILES.product(RANKS)
    coords.each do |coord|
      @squares.push(Square.new(coord))
    end
    set_square_colors
  end

  def set_square_colors
    @squares.each do |square|
      square.color = if (BLACK_FIRST_FILES.include?(square.id[0]) &&
        square.id[1] % 2 == 1) ||
          (WHITE_FIRST_FILES.include?(square.id[0]) && square.id[1] % 2 == 0)
        "black"
      else
        "white"
      end
    end
  end

  # def link_adjacent_squares
  #   @squares.each do |square|
  #     file = square.id[0]
  #     file_i = FILES.find_index(file)
  #     rank = square.id[1]
  #     adj_files = []
  #     adj_files.push(file)
  #     adj_files.push(FILES[file_i - 1]) if file_i > 0
  #     adj_files.push(FILES[file_i + 1]) if file_i < 7
  #     adj_ranks = []
  #     adj_ranks.push(rank)
  #     adj_ranks.push(rank - 1) if rank > 0
  #     adj_ranks.push(rank + 1) if rank < 7
  #     adj_coords = adj_files.product(adj_ranks)
  #   end
  # end
end
