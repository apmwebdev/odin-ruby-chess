# frozen_string_literal: true

class Pieces
  attr_accessor :white_pieces, :white_king, :black_pieces, :black_king
  attr_reader :game, :board

  def initialize(game)
    @game = game
    @board = game.board
    @white_pieces = []
    @white_king = nil
    @black_pieces = []
    @black_king = nil
  end

  def register_pieces
    @board.squares.each do |square|
      case square.id
      in "a1" | "h1"
        register_piece(Rook.new(Game::WHITE, square))
      in "b1" | "g1"
        register_piece(Knight.new(Game::WHITE, square))
      in "c1" | "f1"
        register_piece(Bishop.new(Game::WHITE, square))
      in "d1"
        register_piece(Queen.new(Game::WHITE, square))
      in "e1"
        register_piece(King.new(Game::WHITE, square))
      in /\w2/
        register_piece(Pawn.new(Game::WHITE, square))
      in "a8" | "h8"
        register_piece(Rook.new(Game::BLACK, square))
      in "b8" | "g8"
        register_piece(Knight.new(Game::BLACK, square))
      in "c8" | "f8"
        register_piece(Bishop.new(Game::BLACK, square))
      in "d8"
        register_piece(Queen.new(Game::BLACK, square))
      in "e8"
        register_piece(King.new(Game::BLACK, square))
      in /\w7/
        register_piece(Pawn.new(Game::BLACK, square))
      else
        # Intentionally empty. Present to prevent error
      end
    end
    set_player_data
  end

  def register_piece(piece)
    piece.square.piece = piece
    piece.game = @game
    if piece.color == Game::WHITE
      @white_pieces.push(piece)
      @white_king = piece if piece.name == "King"
      piece.player = @game.white_player
    else
      @black_pieces.push(piece)
      @black_king = piece if piece.name == "King"
      piece.player = @game.black_player
    end
  end

  def set_player_data
    @game.white_player.pieces = @white_pieces
    @game.white_player.king = @white_king
    @game.black_player.pieces = @black_pieces
    @game.black_player.king = @black_king
  end

  def get_piece_at(coord_or_id)
    @board.get_square(coord_or_id).piece
  end

  def promote_pawn(pawn, choice)
    square = pawn.square
    color = pawn.color
    piece = case choice
    when "q"
      Queen.new(color, square)
    when "r"
      Rook.new(color, square)
    when "b"
      Bishop.new(color, square)
    else
      Knight.new(color, square)
    end
    pawn.promoted_to = piece
    piece.promoted_from = pawn
    square.piece = piece
    pawn.square = nil
    register_piece(piece)
    piece
  end
end
