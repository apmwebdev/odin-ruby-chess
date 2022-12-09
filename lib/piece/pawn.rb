# frozen_string_literal: true

class Pawn < Piece
  def get_all_possible_moves
    possible_moves = []
    # TODO: Make colors use the constant. Need to pass Game to Piece
    forward_square = (@color == "white") ? @square.up : @square.down
    # Normal movement
    if forward_square.piece.nil?
      possible_moves.push(forward_square)
      # Move 2 for first move
      up2_square = (@color == "white") ? forward_square.up : forward_square.down
      if !@has_moved && up2_square.piece.nil?
        possible_moves.push(up2_square)
      end
    end
    # Forward left capture
    fwd_left_square = if @color == "white"
      @square.up_left
    else
      @square.down_right
    end
    if fwd_left_square&.piece && fwd_left_square.piece.color != @color
      possible_moves.push(fwd_left_square)
    end
    # Forward right capture
    fwd_right_square = if @color == "white"
      @square.up_right
    else
      @square.down_left
    end
    if fwd_right_square&.piece && fwd_right_square.piece.color != @color
      possible_moves.push(fwd_right_square)
    end
    possible_moves
  end
end
