# frozen_string_literal: true

class Square
  attr_accessor :piece, :color
  attr_reader :id

  def initialize(coordinate, board)
    @id = coordinate
    @board = board
  end

  # def is_adjacent_to?(coord)
  #   @board.is_adjacent_to?(@id, coord)
  # end
  #
  # def is_diagonal_to?(coord)
  #   @board.is_diagonal_to?(@id, coord)
  # end
  #
  # def is_orthogonal_to?(coord)
  #   @board.is_orthogonal_to?(@id, coord)
  # end
  #
  # def knight_can_move_to?(coord)
  #   @board.knight_can_move_to?(@id, coord)
  # end
  #
  # def is_diagonally_adjacent_to?(coord)
  #   @board.is_diagonally_adjacent_to?(@id, coord)
  # end
  #
  # def is_orthogonally_adjacent_to?(coord)
  #   @board.is_orthogonally_adjacent_to?(@id, coord)
  # end
  #
  # def route_is_open_to?(coord)
  #   @board.route_is_open_to?(@id, coord)
  # end
end