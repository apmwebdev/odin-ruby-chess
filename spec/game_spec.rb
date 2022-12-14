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

describe Game do
  describe "#play_game" do
    context "when white and black have taken the same number of turns" do
      subject(:game) { described_class.new }

      before do
        game.break_play_loop = true
        output = instance_double(Output)
        allow(output).to receive(:clear_screen)
        allow(output).to receive(:render_board)
        game.instance_variable_set(:@output, output)
        allow(game).to receive(:show_turn_instructions)
                         .and_return(nil)
        allow(game).to receive(:take_turn).and_return(nil)
        allow(game).to receive(:check_game_status)
      end

      it "is white's turn" do
        expect(game).to receive(:check_game_status).with(game.white_player)
        game.play_game
      end
    end
  end

  describe "#take_turn" do
    context "when given a valid move, e2e4" do
      # subject(:game) { described_class.new }

      it "makes e2 piece nil" do
        game = described_class.new
        player = instance_double(Player, turns_taken: 0)
        allow(player).to receive(:get_move).and_return(%w[e2 e4])
        allow(player).to receive(:turns_taken=)
        game.pieces.register_pieces
        game.take_turn(player)
        e2_piece = game.board.get_square("e2").piece
        expect(e2_piece).to be_nil
      end

      it "makes e4 piece a pawn" do
        game = described_class.new
        player = instance_double(Player, turns_taken: 0)
        allow(player).to receive(:get_move).and_return(%w[e2 e4])
        allow(player).to receive(:turns_taken=)
        game.pieces.register_pieces
        game.take_turn(player)
        e4_piece_name = game.pieces.get_piece_at("e4").name
        expect(e4_piece_name).to eq("Pawn")
      end
    end
  end

  describe "#check_game_status" do
    it "declares current player the winner if opponent is checkmated" do
      game = described_class.new
      allow(game).to receive(:declare_winner).and_return("black wins")
      checkmate_white(game)
      status = game.check_game_status(game.black_player)
      expect(status).to eq("black wins")
    end

    it "declares stalemate if opponent is not in check but can't move" do
      game = described_class.new
      allow(game).to receive(:declare_stalemate).and_return("stalemate")
      stalemate_black(game)
      status = game.check_game_status(game.white_player)
      expect(status).to eq("stalemate")
    end
  end

  describe "#player_is_in_check" do
    context "when white has black's king in check" do
      it "returns true that black is in check" do
        game = described_class.new
        game.pieces.register_pieces
        # Remove pawn in front of black king
        e7 = game.board.get_square("e7")
        e7.piece.is_captured = true
        e7.piece = nil
        # Move white queen in front of black king to put it in check
        d1 = game.board.get_square("d1")
        d1.piece.move_to("e5")
        black_in_check = game.player_is_in_check?(game.black_player)
        expect(black_in_check).to be true
      end
    end

    context "when black's king is not in check" do
      it "returns false that black is in check" do
        game = described_class.new
        game.pieces.register_pieces
        black_in_check = game.player_is_in_check?(game.black_player)
        expect(black_in_check).to be false
      end
    end
  end

  describe "#player_can_attack_square?" do
    it "doesn't let a player attack their own pieces" do
      game = described_class.new
      game.pieces.register_pieces
      white_player = game.white_player
      can_attack = game.player_can_attack_square?(white_player, "c2")
      expect(can_attack).to be false
    end

    it "returns true when checking a blank square in range" do
      game = described_class.new
      game.pieces.register_pieces
      white_player = game.white_player
      can_attack = game.player_can_attack_square?(white_player, "c3")
      expect(can_attack).to be true
    end

    it "returns false for a square out of range of all that player's pieces" do
      game = described_class.new
      game.pieces.register_pieces
      white_player = game.white_player
      can_attack = game.player_can_attack_square?(white_player, "d5")
      expect(can_attack).to be false
    end
  end

  describe "#player_can_move?" do
    context "if a player is in check" do
      it "doesn't allow player to move if they are checkmated" do
        game = described_class.new
        checkmate_white(game)
        white_can_move = game.player_can_move?(game.white_player)
        expect(white_can_move).to be false
      end

      it "allows player to move if they can get out of check" do
        game = described_class.new
        check_white(game)
        white_can_move = game.player_can_move?(game.white_player)
        expect(white_can_move).to be true
      end
    end

    context "if a player is not in check" do
      it "doesn't allow player to move if any move would put them into check" do
        game = described_class.new
        stalemate_black(game)
        black_can_move = game.player_can_move?(game.black_player)
        expect(black_can_move).to be false
      end

      it "allows player to move if they could not end up in check" do
        game = described_class.new
        game.pieces.register_pieces
        white_can_move = game.player_can_move?(game.white_player)
        expect(white_can_move).to be true
      end
    end
  end

  describe "#player_can_castle?" do
    context "when the white kingside castling route is open (f1, g1 empty)" do
      context "when the king has moved previously" do
        it "returns false" do
          game = described_class.new
          game.pieces.register_pieces
          open_white_ks_castling_route(game)
          game.white_player.king.has_moved = true
          castling_rights = game.get_castling_rights
          expect(castling_rights.values).to all(be false)
        end
      end

      context "when the king is in check" do
        it "returns false" do
          game = described_class.new
          game.pieces.register_pieces
          allow(game).to receive(:player_is_in_check?).and_return(true)
          open_white_ks_castling_route(game)
          castling_rights = game.get_castling_rights
          expect(castling_rights.values).to all(be false)
        end
      end

      context "when the rook square is empty" do
        it "returns false" do
          game = described_class.new
          game.pieces.register_pieces
          open_white_ks_castling_route(game)
          game.get_square("h1").piece = nil
          castling_rights = game.get_castling_rights
          expect(castling_rights.values).to all(be false)
        end
      end

      context "when the piece on the rook square has moved previously" do
        it "returns false if the piece is not a rook" do
          game = described_class.new
          game.pieces.register_pieces
          open_white_ks_castling_route(game)
          game.get_square("h1").piece = nil
          game.get_piece_at("d1").move_to("h1")
          castling_rights = game.get_castling_rights
          expect(castling_rights.values).to all(be false)
        end

        it "returns false even if the piece is a rook" do
          game = described_class.new
          game.pieces.register_pieces
          open_white_ks_castling_route(game)
          game.get_piece_at("h1").has_moved = true
          castling_rights = game.get_castling_rights
          expect(castling_rights.values).to all(be false)
        end
      end

      context "when the king would move through a threatened square" do
        it "returns false" do
          game = described_class.new
          game.pieces.register_pieces
          open_white_ks_castling_route(game)
          game.get_square("f2").piece = nil
          game.get_piece_at("h8").move_to("f2")
          castling_rights = game.get_castling_rights
          expect(castling_rights.values).to all(be false)
        end
      end

      context "when the game passes all of the above validation" do
        it "returns true" do
          game = described_class.new
          game.pieces.register_pieces
          open_white_ks_castling_route(game)
          castling_rights = game.get_castling_rights
          expect(castling_rights[:white_can_ks_castle]).to be true
        end
      end
    end

    context "when game conditions should allow white queenside castling" do
      it "allows white queenside castling" do
        game = described_class.new
        game.pieces.register_pieces
        game.get_square("d1").piece = nil
        game.get_square("c1").piece = nil
        game.get_square("b1").piece = nil
        castling_rights = game.get_castling_rights
        expect(castling_rights[:white_can_qs_castle]).to be true
      end
    end

    context "when game conditions should allow black kingside castling" do
      it "allows black kingside castling" do
        game = described_class.new
        game.pieces.register_pieces
        game.get_square("f8").piece = nil
        game.get_square("g8").piece = nil
        castling_rights = game.get_castling_rights
        expect(castling_rights[:black_can_ks_castle]).to be true
      end
    end

    context "when game conditions should allow black queenside castling" do
      it "allows black queenside castling" do
        game = described_class.new
        game.pieces.register_pieces
        game.get_square("d8").piece = nil
        game.get_square("c8").piece = nil
        game.get_square("b8").piece = nil
        castling_rights = game.get_castling_rights
        expect(castling_rights[:black_can_qs_castle]).to be true
      end
    end
  end

  describe "#get_en_passant_rights" do
    context "when conditions are not met for an en passant capture" do
      it "returns empty if move_log is empty" do
        game = described_class.new
        game.pieces.register_pieces
        ep_rights = game.get_en_passant_rights
        expect(ep_rights).to be_empty
      end

      it "returns empty if last move was not a pawn move" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        game.move_log.push game.get_piece_at("d8").move_to("c6")
        ep_rights = game.get_en_passant_rights
        expect(ep_rights).to be_empty
      end

      it "returns empty if last move was a pawn but it had moved prior" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d6")
        game.move_log.push game.get_piece_at("d6").move_to("d5")
        ep_rights = game.get_en_passant_rights
        expect(ep_rights).to be_empty
      end

      it "returns empty if pawn's initial move wasn't 2 squares" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e6")
        game.move_log.push game.get_piece_at("d7").move_to("d6")
        ep_rights = game.get_en_passant_rights
        expect(ep_rights).to be_empty
      end

      it "returns empty if there are no pieces on either side of pawn" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_rights = game.get_en_passant_rights
        expect(ep_rights).to be_empty
      end

      it "returns empty if the adjacent piece isn't also a pawn" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("d1").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_rights = game.get_en_passant_rights
        expect(ep_rights).to be_empty
      end

      it "returns empty if the adjacent pawn is the same color" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e7").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_rights = game.get_en_passant_rights
        expect(ep_rights).to be_empty
      end
    end

    context "when conditions are met for en passant on one side" do
      it "returns an array with length 1" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_rights_length = game.get_en_passant_rights.length
        expect(ep_rights_length).to eq(1)
      end

      it "returns square of piece that can EP capture in start_square" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_start_square = game.get_en_passant_rights[0][:start_square].id
        expect(ep_start_square).to eq("e5")
      end

      it "returns square that EP capture piece will move to in end_square" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_start_square = game.get_en_passant_rights[0][:end_square].id
        expect(ep_start_square).to eq("d6")
      end

      it "returns square of piece to be EP captured in capture_square" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_start_square = game.get_en_passant_rights[0][:capture_square].id
        expect(ep_start_square).to eq("d5")
      end
    end

    context "when conditions are met for en passant on both sides" do
      it "returns an array with length 2" do
        game = described_class.new
        game.pieces.register_pieces
        game.move_log.push game.get_piece_at("e2").move_to("e5")
        game.move_log.push game.get_piece_at("c2").move_to("c5")
        game.move_log.push game.get_piece_at("d7").move_to("d5")
        ep_rights_length = game.get_en_passant_rights.length
        expect(ep_rights_length).to eq(2)
      end
    end
  end

  describe "#can_promote_pawn?" do
    it "returns false if move log is empty" do
      game = described_class.new
      game.pieces.register_pieces
      can_promote = game.can_promote_pawn?
      expect(can_promote).to be false
    end

    it "returns false if the pawn hasn't reached the back rank" do
      game = described_class.new
      game.pieces.register_pieces
      game.move_log.push game.get_piece_at("a2").move_to("a4")
      can_promote = game.can_promote_pawn?
      expect(can_promote).to be false
    end

    context "when a piece reaches the back rank" do
      it "returns false if the piece isn't a pawn" do
        game = described_class.new
        game.pieces.register_pieces
        game.get_square("a7").piece = nil
        game.get_square("a8").piece = nil
        game.move_log.push game.get_piece_at("a1").move_to("a8")
        can_promote = game.can_promote_pawn?
        expect(can_promote).to be false
      end

      it "returns false if the piece was already promoted" do
        # This is relevant when loading saved game data
        game = described_class.new
        game.pieces.register_pieces
        game.get_square("a7").piece = nil
        game.get_square("a8").piece = nil
        move = game.get_piece_at("a2").move_to("a8")
        move.promotion = true
        game.move_log.push(move)
        can_promote = game.can_promote_pawn?
        expect(can_promote).to be false
      end

      it "returns true if the piece is a pawn" do
        game = described_class.new
        game.pieces.register_pieces
        game.get_square("a7").piece = nil
        game.get_square("a8").piece = nil
        game.move_log.push game.get_piece_at("a2").move_to("a8")
        can_promote = game.can_promote_pawn?
        expect(can_promote).to be true
      end
    end
  end
end

def stalemate_black(game)
  # Result: Black only has one piece, the king, and any move it could make would
  # put it under attack from white's queen.
  a1 = game.get_square("a1")
  game.pieces.register_piece(King.new(Game::WHITE, a1))
  g6 = game.get_square("g6")
  game.pieces.register_piece(Queen.new(Game::WHITE, g6))
  h8 = game.get_square("h8")
  game.pieces.register_piece(King.new(Game::BLACK, h8))
  game.pieces.set_player_data
end

def check_white(game)
  # Fool's mate, except e2 pawn has moved forward, allowing king to escape
  game.pieces.register_pieces
  game.pieces.get_piece_at("e2").move_to("e3")
  game.pieces.get_piece_at("f2").move_to("f3")
  game.pieces.get_piece_at("g2").move_to("g4")
  game.pieces.get_piece_at("d8").move_to("h4")
end

def checkmate_white(game)
  # Fool's mate
  game.pieces.register_pieces
  game.pieces.get_piece_at("f2").move_to("f3")
  game.pieces.get_piece_at("g2").move_to("g4")
  game.pieces.get_piece_at("d8").move_to("h4")
end

def open_white_ks_castling_route(game)
  game.get_square("f1").piece = nil
  game.get_square("g1").piece = nil
end
