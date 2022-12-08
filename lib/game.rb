# frozen_string_literal: true

class Game
  attr_accessor :board

  WHITE = "white"
  BLACK = "black"

  def initialize
    @board = Board.new
  end

  def start_game
    place_initial_pieces
  end

  def place_initial_pieces
    @board.squares.each do |square|
      case square.id
      in ["a", 1] | ["h", 1]
        square.piece = Rook.new(WHITE, @board, square)
      in ["b", 1] | ["g", 1]
        square.piece = Knight.new(WHITE, @board, square)
      in ["c", 1] | ["f", 1]
        square.piece = Bishop.new(WHITE, @board, square)
      in ["d", 1]
        square.piece = Queen.new(WHITE, @board, square)
      in ["e", 1]
        square.piece = King.new(WHITE, @board, square)
      in [_, 2]
        square.piece = Pawn.new(WHITE, @board, square)
      in ["a", 8] | ["h", 8]
        square.piece = Rook.new(BLACK, @board, square)
      in ["b", 8] | ["g", 8]
        square.piece = Knight.new(BLACK, @board, square)
      in ["c", 8] | ["f", 8]
        square.piece = Bishop.new(BLACK, @board, square)
      in ["d", 8]
        square.piece = Queen.new(BLACK, @board, square)
      in ["e", 8]
        square.piece = King.new(BLACK, @board, square)
      in [_, 7]
        square.piece = Pawn.new(BLACK, @board, square)
      else
        # Intentionally empty. Present to prevent error
      end
    end
  end
end