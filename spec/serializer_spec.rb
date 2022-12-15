# frozen_string_literal: true

require "json"

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

describe Serializer do
  describe "#serialize_game_data" do
    context "when there has only been one move, e2e4" do
      it "returns an array for :squares" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        data = game.serializer.serialize_game_data
        expect(data[:squares]).to be_an(Array)
      end

      it "makes :squares length be 64" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        data = game.serializer.serialize_game_data
        expect(data[:squares].length).to eq(64)
      end

      it "returns an array for :moves" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        data = game.serializer.serialize_game_data
        expect(data[:moves]).to be_an(Array)
      end

      it "makes :moves length be 1" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        data = game.serializer.serialize_game_data
        expect(data[:moves].length).to eq(1)
      end

      it "returns a hash for :players" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        data = game.serializer.serialize_game_data
        expect(data[:players]).to be_a(Hash)
      end
    end
  end

  describe "#save_game" do
    context "when the game's move log is empty" do
      it "puts an error and cancels" do
        game = Game.new
        game.pieces.register_pieces
        serializer = game.serializer
        expect(serializer).to receive(:puts).with("Save error: No data to save")
        game.serializer.save_game
      end
    end

    context "when 'c' is returned from get_save_file_name" do
      it "doesn't put anything else" do
        # This indicates the save process was terminated
        game = Game.new
        game.pieces.register_pieces
        serializer = game.serializer
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        allow(serializer).to receive(:get_save_file_name).and_return("c")
        expect(serializer.save_game).not_to receive(:puts)
      end
    end
    
    context "when a valid file name is input and that file doesn't exist" do
      it "doesn't receive get_existing_save_file_choice" do
        game = Game.new
        game.pieces.register_pieces
        serializer = game.serializer
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        file_name_input = "rspec_test_save"
        file_name = serializer.get_file_name_from_input(file_name_input)
        File.delete(file_name) if File.exist?(file_name)

        allow(serializer).to receive(:get_save_file_name)
          .and_return(file_name_input)
        allow(serializer).to receive(:write_save_file)
          .and_return("write_save_file")
        allow(serializer).to receive(:puts)

        expect(serializer).not_to receive(:get_existing_save_file_choice)
        serializer.save_game
      end

      it "receives write_save_file" do
        game = Game.new
        game.pieces.register_pieces
        serializer = game.serializer
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        file_name_input = "rspec_test_save"
        file_name = serializer.get_file_name_from_input(file_name_input)
        File.delete(file_name) if File.exist?(file_name)

        allow(serializer).to receive(:get_save_file_name)
          .and_return(file_name_input)
        allow(serializer).to receive(:write_save_file)
        allow(serializer).to receive(:puts)

        expect(serializer).to receive(:write_save_file)
        serializer.save_game
      end
    end
  end

  describe "#get_save_file_name" do
    context "when 'c' is the input" do
      it "displays the prompt, then cancel message, then continue message" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        prompt = "Enter a filename with no file extension (c to cancel):"
        canceled_msg = "Save canceled"
        continue_msg = serializer.continue_text
        allow(serializer).to receive(:gets).and_return("c")
        expect(serializer).to receive(:puts).with(prompt).once
        expect(serializer).to receive(:puts).with(canceled_msg).once
        expect(serializer).to receive(:puts).with(continue_msg).once
        serializer.get_save_file_name
      end
    end

    context "when input is blank" do
      it "displays an error" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        prompt = "Enter a filename with no file extension (c to cancel):"
        error_msg = "Save error: Invalid save file name"
        allow(serializer).to receive(:gets).and_return("")
        expect(serializer).to receive(:puts).with(prompt).once
        expect(serializer).to receive(:puts).with(error_msg).once
        serializer.get_save_file_name
      end
    end

    context "when a valid file name is entered as input" do
      it "returns that input" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        valid_file_name = "test"
        allow(serializer).to receive(:gets).and_return(valid_file_name)
        allow(serializer).to receive(:puts)
        expect(serializer.get_save_file_name).to eq(valid_file_name)
      end
    end
  end

  describe "#get_existing_file_name_choice" do
    context "when answer is o (overwrite existing file)" do
      after do
        file_name = "saved_games/rspec_test_existing_save.json"
        File.delete(file_name) if File.exist?(file_name)
      end

      it "overwrites the existing file" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        file_name_input = "rspec_test_existing_save"
        file_name = serializer.get_file_name_from_input(file_name_input)
        file_initial_content = "test"
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, "w") { |file| file.puts file_initial_content }
        save_data = serializer.serialize_game_data.to_json
        allow(serializer).to receive(:gets).and_return("o")
        allow(serializer).to receive(:puts)

        serializer.get_existing_save_file_choice(file_name, save_data)
        file_first4 = File.open(file_name, "r") { |file| file.sysread(4) }
        expect(file_first4).to_not eq(file_initial_content)
      end

      it "writes the game state JSON string to the file" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        file_name_input = "rspec_test_existing_save"
        file_name = serializer.get_file_name_from_input(file_name_input)
        file_initial_content = "test"
        File.delete(file_name) if File.exist?(file_name)
        File.open(file_name, "w") { |file| file.puts file_initial_content }
        save_data = serializer.serialize_game_data.to_json + "\n"
        allow(serializer).to receive(:gets).and_return("o")
        allow(serializer).to receive(:puts)

        serializer.get_existing_save_file_choice(file_name, save_data)
        file = File.read(file_name)
        expect(file).to eq(save_data)
      end
    end

    context "when answer is n (use a different name)" do
      it "returns #save_game" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        allow(serializer).to receive(:gets).and_return("n")
        allow(serializer).to receive(:save_game).and_return("save_game")
        allow(serializer).to receive(:puts)
        result = serializer.get_existing_save_file_choice(nil, nil)
        expect(result).to eq("save_game")
      end
    end

    context "when answer is c (cancel)" do
      it "displays two messages" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        cancel_msg = "Save canceled"
        continue_msg = serializer.continue_text
        allow(serializer).to receive(:gets).and_return("c")
        allow(serializer).to receive(:puts)

        expect(serializer).to receive(:puts).with(cancel_msg).once
        expect(serializer).to receive(:puts).with(continue_msg).once
        serializer.get_existing_save_file_choice(nil, nil)
      end
    end

    context "when answer is invalid" do
      it "displays an error message" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        error_msg = "Save error: Invalid selection"
        allow(serializer).to receive(:gets).and_return("invalid")
        allow(serializer).to receive(:puts)

        expect(serializer).to receive(:puts).with(error_msg).once
        serializer.get_existing_save_file_choice(nil, nil)
      end
    end
  end

  describe "#get_file_to_load" do
    context "when c is entered" do
      it "displays two messages" do
        game = Game.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e4")
        serializer = game.serializer
        allow(serializer).to receive(:gets).and_return("c")
        allow(serializer).to receive(:puts)

        expect(serializer).to receive(:puts).with("Load canceled")
        serializer.get_file_to_load
      end
    end
  end
end

# TODO: Finish tests for loading game data
