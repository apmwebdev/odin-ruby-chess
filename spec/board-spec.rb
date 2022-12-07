# frozen_string_literal: true

require './lib/board'

describe Board do
  describe "#create_board" do
    subject(:board) { described_class.new }

    it "gives coordinates a1 to the first square" do
      expect(board.squares[0].id).to eq(["a", 1])
    end

    it "gives coordinates a2 to the second square" do
      expect(board.squares[1].id).to eq(["a", 2])
    end

    it "creates 64 squares" do
      expect(board.squares.length).to eq(64)
    end

    it "properly alternates black and white squares" do
      a1 = board.squares[0]
      b1 = board.squares[1]
      c1 = board.squares[2]
      d1 = board.squares[3]
      a2 = board.squares[8]
      b2 = board.squares[9]
      blacks_are_correct = [a1, c1, b2].all? { |i| i.color == "black" }
      whites_are_correct = [b1, d1, a2].all? { |i| i.color == "white" }
      expect(blacks_are_correct && whites_are_correct).to be true
    end
  end
end