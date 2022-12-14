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

describe Input do

  describe "#get_move" do
    context "when a valid move is given" do
      it "returns the formatted valid move" do
        game = instance_double(Game)
        player = instance_double(Player)
        input = described_class.new(player, game)
        allow(input).to receive(:gets).and_return("e2e4")
        allow(input).to receive(:valid_move_input?).and_return("valid move")
        expect(input.get_move).to eq("valid move")
      end
    end

    context "when an invalid move then a valid move is given" do
      it "returns an error once" do
        game = instance_double(Game)
        player = instance_double(Player)
        input = described_class.new(player, game)
        allow(input).to receive(:gets).and_return("invalid", "e2e4")
        allow(input).to receive(:valid_move_input?).and_return(false, true)
        error_message = "Input error! Please enter a valid move"
        expect(input).to receive(:puts).with(error_message).once
        input.get_move
      end
    end
  end

  describe "#valid_move_input?" do
    it "throws error if input != 4 characters" do
      game = instance_double(Game)
      player = instance_double(Player)
      input = described_class.new(player, game)
      invalid_input = "123"
      error = "Input should be 4 characters (start coordinate + end coordinate)"
      expect(input).to receive(:puts).with(error)
      input.valid_move_input?(invalid_input)
    end

    it "throws error if input doesn't match /^[a-h][1-8][a-h][1-8]$/" do
      game = instance_double(Game)
      player = instance_double(Player)
      input = described_class.new(player, game)
      invalid_input = "4e4e"
      error = "Invalid input format. Input should be start + end coordinates"
      expect(input).to receive(:puts).with(error)
      input.valid_move_input?(invalid_input)
    end

    it "throws an error if start and end coordinates are the same" do
      game = instance_double(Game)
      player = instance_double(Player)
      input = described_class.new(player, game)
      invalid_input = "e2e2"
      error = "Start and end coordinates must be different"
      expect(input).to receive(:puts).with(error)
      input.valid_move_input?(invalid_input)
    end

    it "throws an error if there is no piece at the start coordinate" do
      game = Game.new
      game.pieces.register_pieces
      input = game.white_player.input
      invalid_input = "e4e5"
      error = "No piece at e4"
      expect(input).to receive(:puts).with(error)
      input.valid_move_input?(invalid_input)
    end

    it "throws an error if the piece doesn't belong to the player" do
      game = Game.new
      game.pieces.register_pieces
      input = game.white_player.input
      invalid_input = "e7e5"
      error = "You don't control this piece"
      expect(input).to receive(:puts).with(error)
      input.valid_move_input?(invalid_input)
    end

    it "throws an error if the piece can't move to the end coordinate" do
      game = Game.new
      game.pieces.register_pieces
      input = game.white_player.input
      invalid_input = "e2d5"
      error = "This piece can't move there"
      expect(input).to receive(:puts).with(error)
      input.valid_move_input?(invalid_input)
    end

    it "throws an error if the move would result in being checked" do
      game = Game.new
      game.pieces.register_pieces
      input = game.white_player.input
      game.get_piece_at("d8").move_to("g3")
      invalid_input = "f2f3"
      error = "You must defend your king"
      expect(input).to receive(:puts).with(error)
      input.valid_move_input?(invalid_input)
    end

    it "returns an array of the start and end coordinates if input is valid" do
      game = Game.new
      game.pieces.register_pieces
      input = game.white_player.input
      valid_input = "e2e4"
      validated_input = input.valid_move_input?(valid_input)
      expect(validated_input).to eq(%w[e2 e4])
    end
  end

  describe "#get_promotion_choice" do
    context "when an invalid choice then valid choice are submitted" do
      it "throws an error once" do
        game = instance_double(Game)
        player = instance_double(Player)
        input = described_class.new(player, game)
        invalid_promo = "blah"
        valid_promo = "q"
        error = "Input error! Please enter a valid promotion choice"
        allow(input).to receive(:gets).and_return(invalid_promo, valid_promo)
        expect(input).to receive(:puts).with(error).once
        input.get_promotion_choice
      end
    end

    it "returns the input if it's valid" do
      game = instance_double(Game)
      player = instance_double(Player)
      input = described_class.new(player, game)
      valid_promo = "q"
      allow(input).to receive(:gets).and_return(valid_promo)
      expect(input.get_promotion_choice).to eq(valid_promo)
    end
  end
end
