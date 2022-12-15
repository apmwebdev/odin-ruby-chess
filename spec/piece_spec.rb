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

describe Bishop do
  describe "#get_all_possible_moves" do
    context "when on square d4 on an otherwise fresh board" do
      it "returns the correct possible moves" do
        game = Game.new
        game.pieces.register_pieces
        bishop = game.get_piece_at("c1")
        bishop.move_to("d4")
        moves = bishop.get_all_possible_moves.map { |move| move.id }.sort
        expected_moves = %w[c3 e3 c5 b6 a7 e5 f6 g7].sort
        expect(moves).to eq(expected_moves)
      end
    end
  end
end

describe Rook do
  describe "#get_all_possible_moves" do
    context "when on square d4 on an otherwise fresh board" do
      it "returns the correct possible moves" do
        game = Game.new
        game.pieces.register_pieces
        rook = game.get_piece_at("a1")
        rook.move_to("d4")
        moves = rook.get_all_possible_moves.map { |move| move.id }.sort
        expected_moves = %w[d5 d6 d7 d3 a4 b4 c4 e4 f4 g4 h4].sort
        expect(moves).to eq(expected_moves)
      end
    end
  end
end

describe Queen do
  describe "#get_all_possible_moves" do
    context "when on square d4 on an otherwise fresh board" do
      it "returns the correct possible moves" do
        game = Game.new
        game.pieces.register_pieces
        queen = game.get_piece_at("d1")
        queen.move_to("d4")
        moves = queen.get_all_possible_moves.map { |move| move.id }.sort
        rook_moves = %w[d5 d6 d7 d3 a4 b4 c4 e4 f4 g4 h4]
        bishop_moves = %w[c3 e3 c5 b6 a7 e5 f6 g7]
        expected_moves = rook_moves.concat(bishop_moves).sort
        expect(moves).to eq(expected_moves)
      end
    end
  end
end

describe Knight do
  describe "#get_all_possible_moves" do
    context "when on square d4 on an otherwise fresh board" do
      it "returns the correct possible moves" do
        game = Game.new
        game.pieces.register_pieces
        knight = game.get_piece_at("b1")
        knight.move_to("d4")
        moves = knight.get_all_possible_moves.map { |move| move.id }.sort
        expected_moves = %w[c6 e6 b5 b3 f5 f3].sort
        expect(moves).to eq(expected_moves)
      end
    end
  end
end

describe King do
  describe "#get_all_possible_moves" do
    context "when on square d4 on an otherwise fresh board" do
      it "returns all eight adjacent squares" do
        game = Game.new
        game.pieces.register_pieces
        king = game.get_piece_at("e1")
        king.move_to("d4")
        moves = king.get_all_possible_moves.map { |move| move.id }.sort
        expected_moves = %w[c5 d5 e5 e4 e3 d3 c3 c4].sort
        expect(moves).to eq(expected_moves)
      end
    end

    context "when on d5 on an otherwise fresh board" do
      it "does not let king move itself into check" do
        game = Game.new
        game.pieces.register_pieces
        king = game.get_piece_at("e1")
        king.move_to("d5")
        moves = king.get_all_possible_moves.map { |move| move.id }.sort
        expected_moves = %w[e5 e4 d4 c4 c5].sort
        expect(moves).to eq(expected_moves)
      end
    end

    context "when on starting square and able to kingside castle as white" do
      it "returns f1 and g1" do
        game = Game.new
        game.pieces.register_pieces
        king = game.get_piece_at("e1")
        game.get_square("f1").piece = nil
        game.get_square("g1").piece = nil
        moves = king.get_all_possible_moves.map { |move| move.id }.sort
        expected_moves = %w[f1 g1].sort
        expect(moves).to eq(expected_moves)
      end
    end
  end
end

describe Pawn do
  describe "#get_all_possible_moves" do
    context "when looking at the e2 pawn" do
      context "when on starting square on an otherwise fresh board" do
        it "returns the forward two squares" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e2")
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[e3 e4].sort
          expect(moves).to eq(expected_moves)
        end
      end

      context "after already having moved with no capture possibilities" do
        it "returns only the forward square" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e2")
          pawn.move_to("e3")
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[e4].sort
          expect(moves).to eq(expected_moves)
        end
      end

      context "on starting square with capture possibility to upper left" do
        it "returns two forward squares and upper left square" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e2")
          game.get_piece_at("d7").move_to("d3")
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[e3 e4 d3].sort
          expect(moves).to eq(expected_moves)
        end
      end

      context "on starting square with both capture options" do
        it "returns two forward squares, upper left, and upper right" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e2")
          game.get_piece_at("d7").move_to("d3")
          game.get_piece_at("f7").move_to("f3")
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[e3 e4 d3 f3].sort
          expect(moves).to eq(expected_moves)
        end
      end

      context "when on e5 with one en passant possibility to upper left" do
        it "returns e6 and d6" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e2")
          pawn.move_to("e5")
          game.move_log.push(game.get_piece_at("d7").move_to("d5"))
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[d6 e6].sort
          expect(moves).to eq(expected_moves)
        end
      end

      context "when on e5 with one en passant possibility to upper right" do
        it "returns e6 and f6" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e2")
          pawn.move_to("e5")
          game.move_log.push(game.get_piece_at("f7").move_to("f5"))
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[f6 e6].sort
          expect(moves).to eq(expected_moves)
        end
      end
    end

    context "when looking at e7 pawn" do
      context "when on starting square with an otherwise fresh board" do
        it "returns the forward two squares" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e7")
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[e6 e5].sort
          expect(moves).to eq(expected_moves)
        end
      end

      context "on starting square with both capture options" do
        it "returns two forward squares, forward left, and forward right" do
          game = Game.new
          game.pieces.register_pieces
          pawn = game.get_piece_at("e7")
          game.get_piece_at("d2").move_to("d6")
          game.get_piece_at("f2").move_to("f6")
          moves = pawn.get_all_possible_moves.map { |move| move.id }.sort
          expected_moves = %w[e6 e5 d6 f6].sort
          expect(moves).to eq(expected_moves)
        end
      end
    end
  end
end