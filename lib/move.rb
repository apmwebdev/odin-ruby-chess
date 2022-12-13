# frozen_string_literal: true

require "json"
require "digest/md5"

class Move
  attr_reader :piece, :start_square, :end_square, :type, :game
  attr_accessor :captured_piece, :has_moved_prior, :rook, :r_start_square,
    :r_end_square, :captured_piece_square, :promotion, :game_state_checksum

  def initialize(piece, start_square, end_square, type, game)
    @piece = piece
    @start_square = start_square
    @end_square = end_square
    @type = type
    @game = game
  end

  def do
    case @type
    when "normal"
      do_normal_move
    when "castle"
      do_castle_move
    when "ep"
      do_en_passant_move
    end
  end

  def undo
    case @type
    when "normal"
      undo_normal_move
    when "castle"
      undo_castle_move
    when "ep"
      undo_en_passant_move
    end
  end

  def save_game_state
    game_state = @game.serializer.serialize_board_and_rights
    @game_state_checksum = Digest::MD5.hexdigest(game_state.to_json)
  end

  def do_normal_move
    @captured_piece.is_captured = true if @captured_piece
    @captured_piece.square = nil if @captured_piece
    @start_square.piece = nil
    @end_square.piece = @piece
    @piece.square = end_square
    @piece.has_moved = true
  end

  def undo_normal_move
    @piece.has_moved = @has_moved_prior
    @piece.square = @start_square
    @end_square.piece = @captured_piece
    @start_square.piece = @piece
    @captured_piece.square = @end_square if @captured_piece
    @captured_piece.is_captured = false if @captured_piece
  end

  def do_castle_move
    @piece.square.piece = nil
    @end_square.piece = @piece
    @piece.square = end_square
    @piece.has_moved = true
    @r_start_square.piece = nil
    @r_end_square.piece = @rook
    @rook.square = @r_end_square
    @rook.has_moved = true
  end

  def undo_castle_move
    @rook.has_moved = false
    @rook.square = @r_start_square
    @r_end_square.piece = nil
    @r_start_square.piece = @rook
    @piece.has_moved = false
    @piece.square = @start_square
    @end_square.piece = nil
    @start_square.piece = @piece
  end

  def do_en_passant_move
    @captured_piece.is_captured = true
    @captured_piece.square = nil
    @captured_piece_square.piece = nil
    @start_square.piece = nil
    @end_square.piece = @piece
    @piece.square = @end_square
  end

  def undo_en_passant_move
    @piece.square = @start_square
    @end_square.piece = nil
    @start_square.piece = @piece
    @captured_piece_square.piece = @captured_piece
    @captured_piece.square = @captured_piece_square
    @captured_piece.is_captured = false
  end

  def serialize
    {
      piece: @piece.serialize,
      start_square: @start_square.id,
      end_square: @end_square.id,
      type: @type,
      has_moved_prior: @has_moved_prior,
      promotion: @promotion ? @promotion.serialize : nil,
      game_state_checksum: @game_state_checksum
    }
  end
end
