# frozen_string_literal: true

class King < Piece
  def initialize(*args)
    super
    @moves_orthogonally = true
    @moves_diagonally = true
  end
end
