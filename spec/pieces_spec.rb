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

describe Pieces do
  describe "#register_pieces" do
    it "makes each player have 16 pieces" do
      game = Game.new
      game.pieces.register_pieces
      white_piece_count = game.white_player.pieces.length
      black_piece_count = game.black_player.pieces.length
      correct_pieces_count = white_piece_count == 16 && black_piece_count == 16
      expect(correct_pieces_count).to be true
    end

    it "causes both players to have kings" do
      game = Game.new
      game.pieces.register_pieces
      white_king = game.white_player.king
      black_king = game.black_player.king
      have_kings = white_king.is_a?(King) && black_king.is_a?(King)
      expect(have_kings).to be true
    end

    it "causes a1 to have a white rook" do
      game = Game.new
      game.pieces.register_pieces
      a1_piece = game.get_piece_at("a1")
      result = a1_piece.name == "Rook" && a1_piece.color == "white"
      expect(result).to be true
    end

    it "causes d7 to have a black pawn" do
      game = Game.new
      game.pieces.register_pieces
      d7_piece = game.get_piece_at("d7")
      result = d7_piece.name == "Pawn" && d7_piece.color == "black"
      expect(result).to be true
    end
  end

  describe "#promote_pawn" do
    context "when the choice is 'q'" do
      it "returns a Queen instance" do
        game = Game.new
        game.pieces.register_pieces
        pawn = game.get_piece_at("e2")
        choice = "q"
        promotion = game.pieces.promote_pawn(pawn, choice)
        expect(promotion).to be_a(Queen)
      end

      it "returns an instance that's the same color as the pawn" do
        game = Game.new
        game.pieces.register_pieces
        pawn = game.get_piece_at("e2")
        choice = "q"
        promotion = game.pieces.promote_pawn(pawn, choice)
        expect(promotion.color).to eq("white")
      end

      it "replaces the pawn at the correct square (e2)" do
        game = Game.new
        game.pieces.register_pieces
        pawn = game.get_piece_at("e2")
        choice = "q"
        promotion = game.pieces.promote_pawn(pawn, choice)
        expect(promotion.square.id).to eq("e2")
      end

      it "registers the new piece with the square" do
        game = Game.new
        game.pieces.register_pieces
        pawn = game.get_piece_at("e2")
        choice = "q"
        promotion = game.pieces.promote_pawn(pawn, choice)
        expect(promotion.square.piece).to eq(promotion)
      end

      it "registers the new piece with the white player's pieces" do
        game = Game.new
        game.pieces.register_pieces
        pawn = game.get_piece_at("e2")
        choice = "q"
        promotion = game.pieces.promote_pawn(pawn, choice)
        result = game.white_player.pieces.include?(promotion)
        expect(result).to be true
      end
    end
  end
end
