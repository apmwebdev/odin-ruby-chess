# frozen_string_literal: true

class Board
  attr_accessor :squares

  FILES = ("a".."h").to_a
  RANKS = (1..8).to_a
  DARK_FIRST_FILES = %w[a c e g]
  LIGHT_FIRST_FILES = %w[b d f h]

  def initialize
    @squares = []
    create_board
  end

  def create_board
    ids = RANKS.product(FILES)
    ids.each do |id|
      file_num = id[1].bytes[0] - 97
      rank_num = id[0] - 1
      coord = [file_num, rank_num]
      @squares.push(Square.new(id.reverse.join(""), coord, self))
    end
    initialize_square_data
  end

  def get_square(query)
    if query.is_a?(Array)
      @squares.find(proc {}) { |square| square.coord == query }
    else
      @squares.find(proc {}) { |square| square.id == query }
    end
  end

  def initialize_square_data
    @squares.each do |square|
      set_square_color(square)
      link_adjacent_squares(square)
    end
  end

  def set_square_color(square)
    square.color = if (DARK_FIRST_FILES.include?(square.id[0]) &&
      square.id[1].to_i % 2 == 1) ||
        (LIGHT_FIRST_FILES.include?(square.id[0]) && square.id[1].to_i % 2 == 0)
      "dark"
    else
      "light"
    end
  end

  def link_adjacent_squares(square)
    file = square.coord[0]
    rank = square.coord[1]
    square.up = get_square([file, rank + 1])
    square.down = get_square([file, rank - 1])
    square.left = get_square([file - 1, rank])
    square.right = get_square([file + 1, rank])
    square.up_left = get_square([file - 1, rank + 1])
    square.up_right = get_square([file + 1, rank + 1])
    square.down_left = get_square([file - 1, rank - 1])
    square.down_right = get_square([file + 1, rank - 1])
  end
end
