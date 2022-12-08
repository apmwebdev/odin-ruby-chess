# frozen_string_literal: true

class Queen < Piece
  def initialize(*args)
    super
    @moves_orthogonally = true
    @moves_diagonally = true
    @is_rider = true
  end
end
