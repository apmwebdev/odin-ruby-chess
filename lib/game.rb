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
    # play_game
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
    @pieces.get_piece_at(valid_move[0]).move_to(valid_move[1])
    player.turns_taken += 1
  end

  def check_game_status(current_player)
    opponent = (player.color == WHITE) ? @black_player : @white_player
    if player_is_in_check?(opponent)
      return declare_winner(current_player) unless player_can_move?(opponent)
      declare_check(opponent)
    else
      return declare_stalemate unless player_can_move?(opponent)
    end
  end

  def player_is_in_check?(player)
    opponent = (player.color == WHITE) ? @black_player : @white_player
    king_square = player.king.square
    opponent.pieces.each do |piece|
      is_attacking_king = piece.valid_move?(king_square.coord)
      return is_attacking_king if is_attacking_king
    end
    false
  end

  def player_can_move?(player)
    player_moves = player.get_all_possible_moves
    can_move = false
    player_moves.each do |piece_move|
      piece_move => {piece:, move:}
      potential_move = piece.move_to(move.coord)
      can_move = !player_is_in_check?(player)
      piece.undo_move(potential_move)
      return can_move if can_move
    end
    can_move
  end

  def declare_winner(player)
  end

  def declare_check(player)
  end

  def declare_stalemate
  end
end
