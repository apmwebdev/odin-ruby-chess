# frozen_string_literal: true

class Knight < Piece
  def initialize(*args)
    super
    @is_leaper = true
  end
end
