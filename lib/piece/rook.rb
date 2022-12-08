# frozen_string_literal: true

require_relative "../piece"

class Rook < Piece
  def initialize(*args)
    super
    @moves_orthogonally = true
    @is_rider = true
  end
end
