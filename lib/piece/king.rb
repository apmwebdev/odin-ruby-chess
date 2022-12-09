# frozen_string_literal: true

class King < Piece
  def initialize(*args)
    super
    @moves_orthogonally = true
    @moves_diagonally = true
  end

  def get_all_possible_moves
    moves = super
    moves.reject! do |new_square|
      potential_move = move_to(new_square.coord)
      in_check = @game.player_is_in_check?(@player)
      undo_move(potential_move)
      in_check
    end
    moves
  end
end
