# frozen_string_literal: true

class Game
  attr_reader :board, :pieces, :white_player, :black_player, :output,
    :serializer
  attr_accessor :break_play_loop, :move_log

  WHITE = "white"
  BLACK = "black"

  def initialize
    @board = Board.new
    register_players
    @pieces = Pieces.new(self)
    @output = Output.new(self)
    @serializer = Serializer.new(self)
    @move_log = []
    @break_play_loop = false
  end

  def register_players
    @white_player = Player.new(WHITE, self)
    @black_player = Player.new(BLACK, self)
    @white_player.opponent = @black_player
    @black_player.opponent = @white_player
  end

  def start_game
    @pieces.register_pieces
    play_game
  end

  def play_game
    loop do
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
      break if @break_play_loop
    end
  end

  def show_turn_instructions(player)
    return_str = "'s turn. Enter your move and hit Enter.\n\n"
    return_str += "- To enter a move, type the current position of the piece, "
    return_str += "then the ending\nposition, e.g. 'e2e4'.\n"
    return_str += "- For castling, enter the start and end square for the king, "
    return_str += "e.g. 'e1g1'.\n"
    return_str += "- To save the game, enter 's'. To load a game, enter 'l'."
    return_str = "\n#{player.color.capitalize}#{return_str}\n\n"
    puts return_str
    declare_check(player) if player_is_in_check?(player)
  end

  def take_turn(player)
    valid_input = player.get_move
    if valid_input == "s"
      @serializer.save_game
      take_turn(player)
    elsif valid_input == "l"
      load_game
    else
      move = @pieces.get_piece_at(valid_input[0]).move_to(valid_input[1])
      @move_log.push(move)
      player.turns_taken += 1
      move.save_game_state
    end
  end

  def check_game_status(current_player)
    promote_pawn(current_player) if can_promote_pawn?
    if player_is_in_check?(current_player.opponent)
      unless player_can_move?(current_player.opponent)
        declare_winner(current_player)
      end
    elsif !player_can_move?(current_player.opponent)
      declare_stalemate
    end
  end

  def promote_pawn(current_player)
    pawn = @move_log.last.piece
    choice = current_player.input.get_promotion_choice
    promotion = @pieces.promote_pawn(pawn, choice)
    @move_log.last.promotion = promotion
    @move_log.last.save_game_state
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
    @break_play_loop = true
  end

  def declare_check(player)
    puts "#{player.color.capitalize}'s king is in check!"
  end

  def declare_stalemate
    @output.clear_screen
    @output.render_board
    puts "Stalemate. The game is a draw"
    @break_play_loop = true
  end

  def get_castling_rights
    white_can_qs_castle = player_can_castle?(@white_player, "a1")
    white_can_ks_castle = player_can_castle?(@white_player, "h1")
    black_can_qs_castle = player_can_castle?(@black_player, "a8")
    black_can_ks_castle = player_can_castle?(@black_player, "h8")
    {white_can_ks_castle:, white_can_qs_castle:, black_can_ks_castle:,
     black_can_qs_castle:}
  end

  def player_can_castle?(player, rook_coord)
    return false if player.king.has_moved
    return false if player_is_in_check?(player)
    rook_coord_piece = get_piece_at(rook_coord)
    return false if !rook_coord_piece || rook_coord_piece.has_moved

    if rook_coord == "a1"
      return false unless @pieces.get_piece_at("d1").nil?
      return false unless @pieces.get_piece_at("c1").nil?
      return false unless @pieces.get_piece_at("b1").nil?
      return false if player_can_attack_square?(player.opponent, "d1")
      return false if player_can_attack_square?(player.opponent, "c1")
      true
    elsif rook_coord == "h1"
      return false unless @pieces.get_piece_at("f1").nil?
      return false unless @pieces.get_piece_at("g1").nil?
      return false if player_can_attack_square?(player.opponent, "f1")
      return false if player_can_attack_square?(player.opponent, "g1")
      true
    elsif rook_coord == "a8"
      return false unless @pieces.get_piece_at("d8").nil?
      return false unless @pieces.get_piece_at("c8").nil?
      return false unless @pieces.get_piece_at("b8").nil?
      return false if player_can_attack_square?(player.opponent, "d8")
      return false if player_can_attack_square?(player.opponent, "c8")
      true
    elsif rook_coord == "h8"
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
          ep_data = {
            start_square: ep_piece.square,
            end_square: ep_end_square,
            capture_square: move.end_square
          }
          result_array.push(ep_data)
        end
      end
    end
    result_array
  end

  def can_promote_pawn?
    move = @move_log.last
    return false unless move
    move_rank = move.end_square.coord[1]
    move.piece.name == "Pawn" && move_rank == move.piece.promotion_rank &&
      move.promotion.nil?
  end

  def load_game
    @serializer.load_game
    @output.clear_screen
    @output.render_board
    puts "\nGame loaded! Press Enter to continue"
    gets
  end

  # TODO: Refactor calls to use these two methods instead of the downstream ones

  def get_square(coord_or_id)
    @board.get_square(coord_or_id)
  end

  def get_piece_at(coord_or_id)
    @pieces.get_piece_at(coord_or_id)
  end
end
