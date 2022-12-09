# frozen_string_literal: true

class Square
  attr_accessor :piece, :color, :up, :down, :left, :right, :up_left, :up_right,
    :down_left, :down_right
  attr_reader :id, :coord

  def initialize(id, coord, board)
    @id = id
    @coord = coord
    @board = board
  end

  def self.id_to_coord(id)
    id_file = id[0]
    id_rank = id[1]
    coord_file = id_file.bytes[0] - 97
    coord_rank = id_rank - 1
    [coord_file, coord_rank]
  end

  def self.coord_to_id(coord)
    coord_file = coord[0]
    coord_rank = coord[1]
    id_file = (coord_file + 97).chr
    id_rank = (coord_rank + 1).to_s
    id_file + id_rank
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