# frozen_string_literal: true

class Square
  attr_accessor :piece, :color
  attr_reader :id

  def initialize(coordinate)
    @id = coordinate
  end
end