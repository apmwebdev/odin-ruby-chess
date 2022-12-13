# frozen_string_literal: true

require "./lib/board"
require "./lib/square"

describe Board do
  describe "#create_board" do
    subject(:board) { described_class.new }

    it "gives id of a1 to first square" do
      expect(board.squares[0].id).to eq("a1")
    end

    it "gives coordinates of [0, 0] to first square" do
      expect(board.squares[0].coord).to eq([0, 0])
    end

    it "gives id b1 to the second square" do
      expect(board.squares[1].id).to eq("b1")
    end

    it "creates 64 squares" do
      expect(board.squares.length).to eq(64)
    end
  end

  describe "#get_square" do
    subject(:board) { described_class.new }

    context "when given a valid ID string, e4" do
      it "returns the square with id == 'e4'" do
        expect(board.get_square("e4").id).to eq("e4")
      end
    end

    context "when given an invalid ID string, s1" do
      it "returns nil" do
        expect(board.get_square("s1")).to be_nil
      end
    end

    context "when given a valid coordinate array, [3, 4]" do
      it "returns the square with id == 'd5'" do
        expect(board.get_square([3, 4]).id).to eq("d5")
      end
    end

    context "when given an invalid coordinate array, [10, 11]" do
      it "returns nil" do
        expect(board.get_square([10, 11])).to be_nil
      end
    end
  end

  describe "#set_square_color" do
    subject(:board) { described_class.new }

    it "gives color \"dark\" to first square" do
      expect(board.squares[0].color).to eq("dark")
    end

    it "properly alternates light and dark squares" do
      a1 = board.squares[0]
      b1 = board.squares[1]
      c1 = board.squares[2]
      d1 = board.squares[3]
      a2 = board.squares[8]
      b2 = board.squares[9]
      darks_are_correct = [a1, c1, b2].all? { |i| i.color == "dark" }
      lights_are_correct = [b1, d1, a2].all? { |i| i.color == "light" }
      expect(darks_are_correct && lights_are_correct).to be true
    end
  end

  describe "#link_adjacent_squares" do
    subject(:board) { described_class.new }

    it "makes a1.up == a2" do
      expect(board.squares[0].up.id).to eq("a2")
    end

    it "makes a1.right == b1" do
      expect(board.squares[0].right.id).to eq("b1")
    end

    it "makes a1.left == nil" do
      expect(board.squares[0].left).to be_nil
    end

    it "makes e4.up_right == f5" do
      expect(board.get_square("e4").up_right.id).to eq("f5")
    end
  end
end
