# frozen_string_literal: true

class Game
  attr_reader :board, :pieces, :white_player, :black_player, :move_log,
    :output
  attr_accessor :game_over

  WHITE = "white"
  BLACK = "black"

  def initialize
    @board = Board.new
    @white_player = Player.new(WHITE, self)
    @black_player = Player.new(BLACK, self)
    @white_player.opponent = @black_player
    @black_player.opponent = @white_player
    @pieces = Pieces.new(self)
    @output = Output.new(self)
    @move_log = []
    @game_over = false
  end

  def start_game
    @pieces.register_pieces
    play_game
  end

  def play_game
    until @game_over
      @output.clear_screen
      @output.render_board
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
    return_str = "'s turn. Enter your move and hit Enter.\n\n"
    return_str += "- To enter a move, type the current position of the piece, "
    return_str += "then the ending\nposition, e.g. 'e2e4'.\n"
    return_str += "- For castling, enter the start and end square for the king, "
    return_str += "e.g. 'e1g1'."
    return_str = "\n#{player.color.capitalize}#{return_str}\n\n"
    puts return_str
    declare_check(player) if player_is_in_check?(player)
  end

  def take_turn(player)
    valid_move = player.get_move
    @move_log.push(@pieces.get_piece_at(valid_move[0]).move_to(valid_move[1]))
    player.turns_taken += 1
  end

  def check_game_status(current_player)
    if can_promote_pawn?
      pawn = @move_log.last.piece
      choice = current_player.input.get_promotion_choice
      promotion = @pieces.promote_pawn(pawn, choice)
      @move_log.last.promotion = promotion
      @move_log.last.save_game_state
    end
    if player_is_in_check?(current_player.opponent)
      unless player_can_move?(current_player.opponent)
        declare_winner(current_player)
      end
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
      next if piece == player.king || piece.is_captured || piece.promoted_to
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
      potential_move.undo
      return can_move if can_move
    end
    can_move
  end

  def declare_winner(player)
    @output.clear_screen
    @output.render_board
    puts "#{player.color.capitalize} wins!"
    @game_over = true
  end

  def declare_check(player)
    puts "#{player.color.capitalize}'s king is in check!"
  end

  def declare_stalemate
    @output.clear_screen
    @output.render_board
    puts "Stalemate. The game is a draw"
    @game_over = true
  end

  def get_castling_rights
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

  def get_en_passant_rights
    result_array = []
    move = @move_log.last
    if move && move.piece.name == "Pawn" && !move.has_moved_prior &&
        (move.end_square.coord[1] == 3 || move.end_square.coord[1] == 4)
      left_piece = move.end_square.left&.piece
      right_piece = move.end_square.right&.piece
      [left_piece, right_piece].each do |ep_piece|
        if ep_piece && ep_piece.name == "Pawn" &&
            ep_piece.color != move.piece.color
          ep_end_rank = (move.start_square.coord[1] + move.end_square.coord[1]) / 2
          ep_end_file = move.end_square.coord[0]
          ep_end_square = @board.get_square([ep_end_file, ep_end_rank])
          ep_data = {ep_piece:, ep_end_square:, victim: move.piece}
          result_array.push(ep_data)
        end
      end
    end
    result_array
  end

  def can_promote_pawn?
    move = @move_log.last
    move_rank = move.end_square.coord[1]
    move.piece.name == "Pawn" && move_rank == move.piece.promotion_rank
  end
end
