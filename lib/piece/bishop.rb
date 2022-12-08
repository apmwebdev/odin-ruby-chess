# frozen_string_literal: true

class Bishop < Piece
  def initialize(*args)
    super
    @moves_diagonally = true
    @is_rider = true
  end
end
