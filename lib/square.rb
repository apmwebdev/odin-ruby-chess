# frozen_string_literal: true

class Square
  attr_accessor :piece, :color, :up, :down, :left, :right, :up_left, :up_right,
    :down_left, :down_right
  attr_reader :id, :coord

  def initialize(id, coord, board)
    @id = id
    @coord = coord
    @board = board
  end

  def serialize
    {
      id: @id,
      piece: @piece ? @piece.serialize : nil
    }
  end
end
