# frozen_string_literal: true

class Game
  attr_reader :board, :pieces, :white_player, :black_player, :winner

  WHITE = "white"
  BLACK = "black"

  def initialize
    @board = Board.new
    @pieces = Pieces.new(self)
    @white_player = Player.new(WHITE, self)
    @black_player = Player.new(BLACK, self)
    @winner = nil
  end

  def start_game
    @pieces.place_initial_pieces
    play_game
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
      check_game_status
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

  def check_game_status
  end
end