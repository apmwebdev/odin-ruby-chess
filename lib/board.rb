# frozen_string_literal: true

require_relative "square"

class Board
  attr_accessor :squares

  BLACK_FIRST_FILES = %w[a c e g]
  WHITE_FIRST_FILES = %w[b d f h]

  def initialize
    @squares = []
    create_board
  end

  def create_board
    ranks = (1..8).to_a
    files = ("a".."h").to_a
    coords = files.product(ranks)
    coords.each do |coord|
      @squares.push(Square.new(coord))
    end
    set_square_colors
  end

  def set_square_colors
    @squares.each do |square|
      if (BLACK_FIRST_FILES.include?(square.id[0]) &&
          square.id[1] % 2 == 1) ||
          (WHITE_FIRST_FILES.include?(square.id[0]) &&
            square.id[1] % 2 == 0)
        square.color = "black"
      else
        square.color = "white"
      end
    end
  end
end
