# frozen_string_literal: true

require_relative "../lib/board"
require_relative "../lib/game"
require_relative "../lib/input"
require_relative "../lib/move"
require_relative "../lib/output"
require_relative "../lib/piece"
require_relative "../lib/pieces"
require_relative "../lib/player"
require_relative "../lib/serializer"
require_relative "../lib/square"
require_relative "../lib/piece/bishop"
require_relative "../lib/piece/king"
require_relative "../lib/piece/knight"
require_relative "../lib/piece/pawn"
require_relative "../lib/piece/queen"
require_relative "../lib/piece/rook"

describe Move do
  describe "#do_normal_move" do
    it "makes captured_piece is_captured = true" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("d7").move_to("d3")
      move = game.get_piece_at("e2").move_to("d3")
      expect(move.captured_piece.is_captured).to be true
    end

    it "makes captured_piece.square = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("d7").move_to("d3")
      move = game.get_piece_at("e2").move_to("d3")
      expect(move.captured_piece.square).to be_nil
    end

    it "makes start_square.piece = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("d7").move_to("d3")
      move = game.get_piece_at("e2").move_to("d3")
      expect(move.start_square.piece).to be_nil
    end

    it "makes end_square.piece = piece" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("d7").move_to("d3")
      move = game.get_piece_at("e2").move_to("d3")
      expect(move.end_square.piece).to eq(move.piece)
    end

    it "makes piece.square = end_square" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("d7").move_to("d3")
      move = game.get_piece_at("e2").move_to("d3")
      expect(move.piece.square).to eq(move.end_square)
    end

    it "makes piece.has_moved = true" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("d7").move_to("d3")
      move = game.get_piece_at("e2").move_to("d3")
      expect(move.piece.has_moved).to be true
    end
  end

  describe "#undo_normal_move" do
    it "returns all fields to their original state" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("d7").move_to("d3")
      move = game.get_piece_at("e2").move_to("d3")
      move.undo
      captured_piece = move.captured_piece
      start_square = move.start_square
      end_square = move.end_square
      piece = move.piece
      did_undo_correctly = (
        captured_piece.is_captured == false &&
          captured_piece.square == end_square &&
          piece.square == start_square &&
          piece.has_moved == move.has_moved_prior &&
          start_square.piece == piece &&
          end_square.piece == captured_piece
      )
      expect(did_undo_correctly).to be true
    end
  end

  describe "#do_castle_move" do
    it "makes start_square.piece = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.start_square.piece).to be_nil
    end

    it "makes end_square.piece = piece" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.end_square.piece).to eq(move.piece)
    end

    it "makes piece.square = end_square" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.piece.square).to eq(move.end_square)
    end

    it "makes piece.has_moved = true" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.start_square.piece).to be_nil
    end

    it "makes r_start_square.piece = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.r_start_square.piece).to be_nil
    end

    it "makes r_end_square.piece = rook" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.r_end_square.piece).to eq(move.rook)
    end

    it "makes rook.square = r_end_square" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.rook.square).to eq(move.r_end_square)
    end

    it "makes rook.has_moved = true" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      expect(move.rook.has_moved).to be true
    end
  end

  describe "#undo_castle_move" do
    it "returns all fields to their original state" do
      game = Game.new
      game.pieces.register_pieces
      game.get_square("f1").piece = nil
      game.get_square("g1").piece = nil
      move = game.get_piece_at("e1").move_to("g1")
      move.undo
      start_square = move.start_square
      end_square = move.end_square
      piece = move.piece
      rook = move.rook
      r_start_square = move.r_start_square
      r_end_square = move.r_end_square
      did_undo_correctly = (
        start_square.piece == piece &&
        end_square.piece.nil? &&
        piece.square == start_square &&
        piece.has_moved == false &&
        r_start_square.piece == rook &&
        r_end_square.piece.nil? &&
        rook.square == r_start_square &&
        rook.has_moved == false
      )
      expect(did_undo_correctly).to be true
    end
  end

  describe "#do_en_passant_move" do
    it "makes captured_piece.is_captured = true" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      expect(move.captured_piece.is_captured).to be true
    end

    it "makes captured_piece.square = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      expect(move.captured_piece.square).to be_nil
    end

    it "makes captured_square.piece = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      expect(move.captured_square.piece).to be_nil
    end

    it "makes start_square.piece = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      expect(move.start_square.piece).to be_nil
    end

    it "makes end_square.piece = piece" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      expect(move.end_square.piece).to eq(move.piece)
    end

    it "makes piece.square = end_square" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      expect(move.piece.square).to eq(move.end_square)
    end
  end

  describe "#undo_en_passant_move" do
    it "makes piece.square = start_square" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      move.undo
      expect(move.piece.square).to eq(move.start_square)
    end

    it "makes end_square.piece = nil" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      move.undo
      expect(move.end_square.piece).to be_nil
    end

    it "makes start_square.piece = piece" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      move.undo
      expect(move.start_square.piece).to eq(move.piece)
    end

    it "makes captured_square.piece = captured_piece" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      move.undo
      expect(move.captured_square.piece).to eq(move.captured_piece)
    end

    it "makes captured_piece.square = captured_square" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      move.undo
      expect(move.captured_piece.square).to eq(move.captured_square)
    end

    it "makes captured_piece.is_captured = false" do
      game = Game.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("e2").move_to("e5")
      game.move_log.push game.get_piece_at("d7").move_to("d5")
      move = game.get_piece_at("e5").move_to("d6")
      move.undo
      expect(move.captured_piece.is_captured).to be false
    end
  end
end
