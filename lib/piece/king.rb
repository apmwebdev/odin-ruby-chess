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
      potential_move.undo
      in_check
    end

    castling_rights = @game.get_castling_rights
    if @color == Game::WHITE
      if castling_rights[:white_can_qs_castle]
        moves.push(get_square("c1"))
      end
      if castling_rights[:white_can_ks_castle]
        moves.push(get_square("g1"))
      end
    else
      if castling_rights[:black_can_qs_castle]
        moves.push(get_square("c8"))
      end
      if castling_rights[:black_can_ks_castle]
        moves.push(get_square("g8"))
      end
    end

    moves
  end

  def move_to(new_position)
    if !@has_moved && (new_position == "c1" || new_position == "g1" ||
      new_position == "c8" || new_position == "g8")
      case new_position
      when "c1"
        castle(get_square(new_position), get_square("a1"), get_square("d1"))
      when "g1"
        castle(get_square(new_position), get_square("h1"), get_square("f1"))
      when "c8"
        castle(get_square(new_position), get_square("a8"), get_square("d8"))
      when "g8"
        castle(get_square(new_position), get_square("h8"), get_square("f8"))
      end
    else
      super
    end
  end

  def castle(end_square, r_start_square, r_end_square)
    rook = r_start_square.piece

    move = Move.new(self, @square, end_square, "castle", @game)
    move.rook = rook
    move.r_start_square, move.r_end_square = r_start_square, r_end_square
    move.do_move

    move
  end

  def get_square(coord_or_id)
    @game.board.get_square(coord_or_id)
  end
end


