# frozen_string_literal: true

class Pawn < Piece
  WHITE = Game::WHITE

  def get_all_possible_moves
    possible_moves = []
    # Normal movement
    if fwd_square&.piece.nil?
      possible_moves.push(fwd_square)
    end
    # Move 2 for first move
    if !@has_moved && fwd2_square.piece.nil?
      possible_moves.push(fwd2_square)
    end

    # Capture, including en passant
    en_passant_rights = @game.get_en_passant_rights
    # Forward left capture or en passant
    unless en_passant_rights.empty?
      fwd_left_ep = en_passant_rights.find do |ep|
        ep[:start_square] == @square && ep[:end_square] == fwd_left_square
      end
    end
    if (fwd_left_square&.piece && fwd_left_square.piece.color != @color) ||
        fwd_left_ep
      possible_moves.push(fwd_left_square)
    end
    # Forward right capture or en passant
    unless en_passant_rights.empty?
      fwd_right_ep = en_passant_rights.find do |ep|
        ep[:start_square] == @square && ep[:end_square] == fwd_right_square
      end
    end
    if (fwd_right_square&.piece && fwd_right_square.piece.color != @color) ||
        fwd_right_ep
      possible_moves.push(fwd_right_square)
    end
    possible_moves
  end

  def move_to(new_position)
    end_square = @game.board.get_square(new_position)
    end_sq_piece = end_square.piece
    if end_sq_piece.nil? && (end_square == fwd_left_square ||
      end_square == fwd_right_square)
      # en passant capture
      start_square = @square
      captured_piece = if end_square == fwd_left_square
        left_square.piece
      else
        right_square.piece
      end
      captured_piece_square = captured_piece.square

      move = Move.new(self, start_square, end_square, "ep", @game)
      move.captured_piece = captured_piece
      move.captured_square = captured_piece_square
      move.do_move

      move
    else
      super
    end
  end

  def fwd_square
    (@color == WHITE) ? @square.up : @square.down
  end

  def fwd2_square
    (@color == WHITE) ? fwd_square.up : fwd_square.down
  end

  def fwd_left_square
    (@color == WHITE) ? @square.up_left : @square.down_right
  end

  def fwd_right_square
    (@color == WHITE) ? @square.up_right : @square.down_left
  end

  def left_square
    (@color == WHITE) ? @square.left : @square.right
  end

  def right_square
    (@color == WHITE) ? @square.right : @square.left
  end

  def promotion_rank
    (@color == WHITE) ? 7 : 0
  end
end
