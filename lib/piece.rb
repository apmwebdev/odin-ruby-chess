# frozen_string_literal: true

class Piece
  attr_accessor :has_moved, :position
  attr_reader :moves_orthogonally, :moves_diagonally, :is_rider, :is_leaper,
    :name, :color

  def initialize(color, board, square)
    @name = self.class.name.split("::").last
    @color = color
    @board = board
    @square = square
  end

  def valid_move?(end_coord)
    end_square = @board.get_square(end_coord)
    return false if @color == end_square.piece.color && @name != "King"
    return false if !@is_leaper && !route_is_open_to?(end_coord)
    if is_orthogonal_to?(end_coord)
      @moves_orthogonally && (@is_rider || is_adjacent_to?(end_coord))
    elsif is_diagonal_to?(end_coord)
      @moves_diagonally && (@is_rider || is_adjacent_to?(end_coord))
    end
  end

  def move_to(new_position)
    @square.piece = nil
    @square = @board.get_square(new_position)
    @square.piece = self
    @has_moved = true
  end

  def is_adjacent_to?(coord)
    @board.is_adjacent_to?(@square.id, coord)
  end

  def is_diagonal_to?(coord)
    @board.is_diagonal_to?(@square.id, coord)
  end

  def is_orthogonal_to?(coord)
    @board.is_orthogonal_to?(@square.id, coord)
  end

  def knight_can_move_to?(coord)
    @board.knight_can_move_to?(@square.id, coord)
  end

  # def is_diagonally_adjacent_to?(coord)
  #   @board.is_diagonally_adjacent_to?(@square.id, coord)
  # end
  #
  # def is_orthogonally_adjacent_to?(coord)
  #   @board.is_orthogonally_adjacent_to?(@square.id, coord)
  # end

  def route_is_open_to?(coord)
    @board.route_is_open_to?(@square.id, coord)
  end

end