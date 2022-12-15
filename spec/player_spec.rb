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

describe Player do
  describe "#get_all_possible_moves" do
    context "when it's the start of the game" do
      it "returns an array of size 20 for white" do
        game = Game.new
        game.pieces.register_pieces
        possible_moves = game.white_player.get_all_possible_moves
        expect(possible_moves.length).to eq(20)
      end

      it "returns an array of size 19 if f2 pawn is removed" do
        game = Game.new
        game.pieces.register_pieces
        game.get_piece_at("f2").is_captured = true
        game.get_square("f2").piece = nil
        possible_moves = game.white_player.get_all_possible_moves
        expect(possible_moves.length).to eq(19)
      end
    end

    it "doesn't get moves for captured pieces" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("b1").is_captured = true
      possible_moves = game.white_player.get_all_possible_moves
      expect(possible_moves.length).to eq(18)
    end

    it "doesn't get moves for promoted pawns" do
      game = Game.new
      game.pieces.register_pieces
      game.get_piece_at("f2").promoted_to = true
      possible_moves = game.white_player.get_all_possible_moves
      expect(possible_moves.length).to eq(18)
    end

    it "consists of hashes with a Piece (:piece) and a Square (:move)" do
      game = Game.new
      game.pieces.register_pieces
      possible_moves = game.white_player.get_all_possible_moves
      last_move = possible_moves.last
      result = last_move[:piece].is_a?(Piece) && last_move[:move].is_a?(Square)
      expect(result).to be true
    end
  end
end
