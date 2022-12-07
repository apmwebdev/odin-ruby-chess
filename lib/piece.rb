# frozen_string_literal: true

class Piece
  attr_accessor :has_moved, :position
  attr_reader :moves_orthagonally, :moves_diagonally, :is_rider, :is_leaper

  def initialize(color, squares, current_square)
    @color = color
    @squares = squares
    @current_square = current_square
  end

  def valid_move?(new_pos)

  end

  def move_to(new_position)

  end

end