# frozen_string_literal: true

require "json"

class Serializer
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def serialize_game_data
    serialize_board_and_rights => {squares:, castling_rights:, ep_rights:}
    moves = @game.move_log.map { |move| move.serialize }
    players = {
      white: @game.white_player.turns_taken,
      black: @game.black_player.turns_taken
    }
    {squares:, moves:, players:}
  end

  def serialize_board_and_rights
    squares = @game.board.squares.map { |square| square.serialize }
    castling_rights = @game.get_castling_rights
    ep_rights = serialize_ep_rights(@game.get_en_passant_rights)
    {squares:, castling_rights:, ep_rights:}
  end

  def serialize_ep_rights(ep_rights_arr)
    ep_rights_arr.map do |data|
      data => {start_square:, end_square:, capture_square:}
      start_square = start_square.id
      end_square = end_square.id
      capture_square = capture_square.id
      {start_square:, end_square:, capture_square:}
    end
  end

  def continue_text
    "You may continue with the game. Enter your move:"
  end

  def save_game
    move_log = @game.move_log
    return puts "Save error: No data to save" if move_log.empty?
    file_name_input = ""
    loop do
      file_name_input = get_save_file_name
      return if file_name_input == "c"
      break if file_name_input.length > 0
    end
    save_data = serialize_game_data.to_json
    file_name = get_file_name_from_input(file_name_input)
    if File.exist?(file_name)
      get_existing_save_file_choice(file_name, save_data)
    else
      write_save_file(file_name, save_data)
    end
  end

  def get_file_name_from_input(input)
    "saved_games/#{input}.json"
  end

  def get_save_file_name
    puts "Enter a filename with no file extension (c to cancel):"
    file_name_input = gets.chomp
    if file_name_input == ""
      puts "Save error: Invalid save file name"
    elsif file_name_input == "c"
      puts "Save canceled"
      puts continue_text
    end
    file_name_input
  end

  def get_existing_save_file_choice(file_name, save_data)
    loop do
      puts_str = "A file already exists with this name. Overwrite?"
      puts_str += "\n\no to overwrite\nn to use a different name\nc to cancel"
      puts puts_str
      answer = gets.chomp
      if answer == "o"
        File.truncate(file_name, 0)
        return write_save_file(file_name, save_data)
      elsif answer == "n"
        return save_game
      elsif answer == "c"
        puts "Save canceled"
        return puts continue_text
      else
        return puts "Save error: Invalid selection"
      end
    end
  end

  def write_save_file(file_name, save_data)
    File.open(file_name, "w") { |file| file.puts save_data }
    puts "Game saved!"
    puts continue_text
  end

  def load_game
    file_contents = get_file_to_load
    return unless file_contents
    reset_game_data
    squares_data = file_contents["squares"]
    moves_data = file_contents["moves"]
    players_data = file_contents["players"]

    load_squares_and_pieces(squares_data)
    load_moves(moves_data)
    @game.white_player.turns_taken = players_data["white"]
    @game.black_player.turns_taken = players_data["black"]
  end

  def get_file_to_load
    puts "Enter file name to load (c to cancel):"
    file_name_input = gets.chomp
    if file_name_input == "c"
      puts "Load canceled"
      return puts continue_text
    end
    file_name = "saved_games/#{file_name_input}.json"
    if File.exist?(file_name)
      save_file = File.open(file_name, "r")
      save_file_contents = save_file.read
      save_file.close
      JSON.parse(save_file_contents)
    else
      puts "Load error: File not found"
      get_file_to_load
    end
  end

  def reset_game_data
    @game.board.squares.each { |square| square.piece = nil }
    @game.move_log = []

    @game.white_player.pieces = []
    @game.white_player.king = nil
    @game.black_player.pieces = []
    @game.black_player.king = nil

    @game.pieces.white_pieces = []
    @game.pieces.white_king = nil
    @game.pieces.black_pieces = []
    @game.pieces.black_king = nil
  end

  def load_moves(moves_data)
    moves_data.each do |move_data|
      piece_name = move_data["piece"]["name"]
      piece_color = move_data["piece"]["color"]
      start_square = @game.board.get_square(move_data["start_square"])
      end_square = @game.board.get_square(move_data["end_square"])
      type = move_data["type"]
      piece = recreate_piece(piece_name, piece_color, true, end_square)
      promotion = if move_data["promotion"]
        promo_name = move_data["promotion"]["name"]
        recreate_piece(promo_name, piece_color, true, end_square)
      end

      move = Move.new(piece, start_square, end_square, type, @game)
      move.has_moved_prior = move_data["has_moved_prior"]
      move.promotion = promotion
      move.game_state_checksum = move_data["game_state_checksum"]

      @game.move_log.push(move)
    end
  end

  def load_squares_and_pieces(data)
    data.each do |square_data|
      square = @game.board.get_square(square_data["id"])
      if square_data["piece"]
        piece_name = square_data["piece"]["name"]
        piece_color = square_data["piece"]["color"]
        piece_has_moved = square_data["piece"]["has_moved"]
        piece = recreate_piece(piece_name, piece_color, piece_has_moved, square)
        @game.pieces.register_piece(piece)
      end
    end
    @game.pieces.set_player_data
  end

  def recreate_piece(name, color, has_moved, square)
    piece = case name
    when "King"
      King.new(color, square)
    when "Queen"
      Queen.new(color, square)
    when "Rook"
      Rook.new(color, square)
    when "Bishop"
      Bishop.new(color, square)
    when "Knight"
      Knight.new(color, square)
    when "Pawn"
      Pawn.new(color, square)
    end
    piece.has_moved = has_moved
    piece
  end
end
