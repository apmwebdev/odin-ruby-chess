# frozen_string_literal: true

require_relative "game"
require_relative "board"
require_relative "piece"
require_relative "piece/bishop"
require_relative "piece/king"
require_relative "piece/knight"
require_relative "piece/pawn"
require_relative "piece/queen"
require_relative "piece/rook"

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
        register_piece(Rook.new(Game::WHITE, @board, square))
      in "b1" | "g1"
        register_piece(Knight.new(Game::WHITE, @board, square))
      in "c1" | "f1"
        register_piece(Bishop.new(Game::WHITE, @board, square))
      in "d1"
        register_piece(Queen.new(Game::WHITE, @board, square))
      in "e1"
        register_piece(King.new(Game::WHITE, @board, square))
      in /\w2/
        register_piece(Pawn.new(Game::WHITE, @board, square))
      in "a8" | "h8"
        register_piece(Rook.new(Game::BLACK, @board, square))
      in "b8" | "g8"
        register_piece(Knight.new(Game::BLACK, @board, square))
      in "c8" | "f8"
        register_piece(Bishop.new(Game::BLACK, @board, square))
      in "d8"
        register_piece(Queen.new(Game::BLACK, @board, square))
      in "e8"
        register_piece(King.new(Game::BLACK, @board, square))
      in /\w7/
        register_piece(Pawn.new(Game::BLACK, @board, square))
      else
        # Intentionally empty. Present to prevent error
      end
    end
    @game.white_player.pieces = @white_pieces
    @game.white_player.king = @white_king
    @game.black_player.pieces = @black_pieces
    @game.black_player.king = @black_king
  end

  def register_piece(piece)
    piece.square.piece = piece
    if piece.color == Game::WHITE
      @white_pieces.push(piece)
      @white_king = piece if piece.name == "King"
    else
      @black_pieces.push(piece)
      @black_king = piece if piece.name == "King"
    end
  end

  def get_piece_at(coord_or_id)
    @board.get_square(coord_or_id).piece
  end
end
