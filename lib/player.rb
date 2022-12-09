# frozen_string_literal: true

require_relative "game"
require_relative "input"

class Player
  attr_accessor :turns_taken, :pieces, :king
  attr_reader :color, :goes_first, :game, :input

  def initialize(color, game)
    @color = color
    @game = game
    @goes_first = @color == Game::WHITE
    @turns_taken = 0
    @input = Input.new(self, @game)
    @pieces = nil
    @king = nil
  end

  def get_move
    @input.get_move
  end
end
