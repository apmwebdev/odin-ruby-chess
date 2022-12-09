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
    @pieces.register_pieces
    play_game
  end

  def play_game
    until @winner
      current_player = if @white_player.turns_taken == @black_player.turns_taken
        @white_player
      else
        @black_player
      end
      show_turn_instructions(current_player)
      take_turn(current_player)
      check_game_status(current_player)
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

  def check_game_status(current_player)
    opponent = (player.color == WHITE) ? @black_player : @white_player
    return declare_winner(current_player) if player_is_checkmated?(opponent)
    declare_check(opponent) if player_is_in_check?(opponent)
  end

  def player_is_in_check?(player)
    opponent = (player.color == WHITE) ? @black_player : @white_player
    king_square = player.king.square
    opponent.pieces.each do |piece|
      can_check = piece.valid_move?(king_square.id)
      return can_check if can_check
    end
    false
  end

  def player_is_checkmated?(player)
  end

  def declare_winner(player)
  end

  def declare_check(player)
  end
end
