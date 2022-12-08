# frozen_string_literal: true

class Game
  attr_reader :board, :white_player, :white_pieces, :white_king, :black_player,
    :black_pieces, :black_king, :winner

  WHITE = "white"
  BLACK = "black"

  def initialize
    @board = Board.new
    @white_player = Player.new(WHITE, self)
    @white_pieces = []
    @white_king = nil
    @black_player = Player.new(BLACK, self)
    @black_pieces = []
    @black_king = nil
    @winner = nil
  end

  def start_game
    place_initial_pieces
    play_game
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
    if piece.color == WHITE
      @white_pieces.push(piece)
      @white_king = piece if piece.name == "King"
    else
      @black_pieces.push(piece)
      @black_king = piece if piece.name == "King"
    end
  end

  def play_game
    until @winner
      if @white_player.turns_taken == @black_player.turns_taken
        show_turn_instructions(@white_player)
        take_turn(@white_player)
      else
        show_turn_instructions(@black_player)
        take_turn(@black_player)
      end
      check_for_win
    end
  end

  def show_turn_instructions(player)
    return_str = "'s turn. Enter your move and hit Enter.\n"
    return_str += "To enter a move, type the current position of the piece, "
    return_str += " then the ending position, e.g. 'e2e4'"
    "#{player.color.capitalize}#{return_str}"
  end

  def take_turn(player)
    valid_move = player.get_move
    get_piece_at(valid_move[0]).move_to(valid_move[1])
    player.turns_taken += 1
  end

  def check_for_win
  end

  def get_piece_at(coord)
    @board.get_square(coord).piece
  end
end