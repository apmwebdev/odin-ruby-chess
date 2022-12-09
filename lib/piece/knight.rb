# frozen_string_literal: true

class Knight < Piece
  def initialize(*args)
    super
    @is_leaper = true
  end

  def get_all_possible_moves
    file = @square.coord[0]
    rank = @square.coord[1]
    @board.squares.filter do |new_square|
      next if new_square == @square
      next if new_square.piece && new_square.piece.color == @color
      new_file = new_square.coord[0]
      new_rank = new_square.coord[1]
      file_change = (file - new_file).abs
      rank_change = (rank - new_rank).abs
      [file_change, rank_change].sort == [1, 2]
    end
  end
end
