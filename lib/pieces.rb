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

  def place_initial_pieces
    @board.squares.each do |square|
      case square.id
      in ["a", 1] | ["h", 1]
        register_piece(Rook.new(WHITE, @board, square))
      in ["b", 1] | ["g", 1]
        register_piece(Knight.new(WHITE, @board, square))
      in ["c", 1] | ["f", 1]
        register_piece(Bishop.new(WHITE, @board, square))
      in ["d", 1]
        register_piece(Queen.new(WHITE, @board, square))
      in ["e", 1]
        register_piece(King.new(WHITE, @board, square))
      in [_, 2]
        register_piece(Pawn.new(WHITE, @board, square))
      in ["a", 8] | ["h", 8]
        register_piece(Rook.new(BLACK, @board, square))
      in ["b", 8] | ["g", 8]
        register_piece(Knight.new(BLACK, @board, square))
      in ["c", 8] | ["f", 8]
        register_piece(Bishop.new(BLACK, @board, square))
      in ["d", 8]
        register_piece(Queen.new(BLACK, @board, square))
      in ["e", 8]
        register_piece(King.new(BLACK, @board, square))
      in [_, 7]
        register_piece(Pawn.new(BLACK, @board, square))
      else
        # Intentionally empty. Present to prevent error
      end
    end
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

  def get_piece_at(coord)
    @board.get_square(coord).piece
  end
end
