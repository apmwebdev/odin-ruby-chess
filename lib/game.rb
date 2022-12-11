# frozen_string_literal: true

class Game
  attr_reader :board, :pieces, :white_player, :black_player, :winner

  WHITE = "white"
  BLACK = "black"

  def initialize
    @board = Board.new
    @white_player = Player.new(WHITE, self)
    @black_player = Player.new(BLACK, self)
    @white_player.opponent = @black_player
    @black_player.opponent = @white_player
    @pieces = Pieces.new(self)
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
    if player_is_in_check?(current_player.opponent)
      unless player_can_move?(current_player.opponent)
        return declare_winner(current_player)
      end
      declare_check(current_player.opponent)
    else
      return declare_stalemate unless player_can_move?(current_player.opponent)
    end
  end

  def player_is_in_check?(player)
    king_coord = player.king.square.coord
    player_can_attack_square?(player.opponent, king_coord)
  end

  def player_can_attack_square?(player, coord)
    coord_piece = @pieces.get_piece_at(coord)
    return false if coord_piece && coord_piece.color == player.color
    player.pieces.each do |piece|
      next if piece == player.king
      can_attack = piece.valid_move?(coord)
      return can_attack if can_attack
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

  def assess_castling_rights
    white_can_ks_castle, white_can_qs_castle = false, false
    black_can_ks_castle, black_can_qs_castle = false, false
    unless @white_player.king.has_moved || player_is_in_check?(@white_player)
      white_can_qs_castle = player_can_castle?(@white_player, "a1")
      white_can_ks_castle = player_can_castle?(@white_player, "h1")
    end
    unless @black_player.king.has_moved || player_is_in_check?(@black_player)
      black_can_qs_castle = player_can_castle?(@black_player, "a8")
      black_can_ks_castle = player_can_castle?(@black_player, "h8")
    end
    {white_can_ks_castle:, white_can_qs_castle:, black_can_ks_castle:,
     black_can_qs_castle:}
  end

  def player_can_castle?(player, rook_coord)
    if rook_coord == "a1"
      a1_piece = @pieces.get_piece_at("a1")
      return false if !a1_piece || a1_piece.has_moved
      return false unless @pieces.get_piece_at("d1").nil?
      return false unless @pieces.get_piece_at("c1").nil?
      return false unless @pieces.get_piece_at("b1").nil?
      return false if player_can_attack_square?(player.opponent, "d1")
      return false if player_can_attack_square?(player.opponent, "c1")
      true
    elsif rook_coord == "h1"
      h1_piece = @pieces.get_piece_at("h1")
      return false if !h1_piece || h1_piece.has_moved
      return false unless @pieces.get_piece_at("f1").nil?
      return false unless @pieces.get_piece_at("g1").nil?
      return false if player_can_attack_square?(player.opponent, "f1")
      return false if player_can_attack_square?(player.opponent, "g1")
      true
    elsif rook_coord == "a8"
      a8_piece = @pieces.get_piece_at("a8")
      return false if !a8_piece || a8_piece.has_moved
      return false unless @pieces.get_piece_at("d8").nil?
      return false unless @pieces.get_piece_at("c8").nil?
      return false unless @pieces.get_piece_at("b8").nil?
      return false if player_can_attack_square?(player.opponent, "d8")
      return false if player_can_attack_square?(player.opponent, "c8")
      true
    elsif rook_coord == "h8"
      h8_piece = @pieces.get_piece_at("h8")
      return false if !h8_piece || h8_piece.has_moved
      return false unless @pieces.get_piece_at("f8").nil?
      return false unless @pieces.get_piece_at("g8").nil?
      return false if player_can_attack_square?(player.opponent, "f8")
      return false if player_can_attack_square?(player.opponent, "g8")
      true
    end
  end
end
