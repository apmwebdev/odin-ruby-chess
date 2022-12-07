# frozen_string_literal: true

class Rook < Piece
  def initialize(*args)
    super
    @moves_orthagonally = true
    @is_rider = true
  end
end
