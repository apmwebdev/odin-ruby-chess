# frozen_string_literal: true

class Player
  attr_accessor :turns_taken, :pieces, :king, :opponent
  attr_reader :color, :goes_first, :game, :input

  def initialize(color, game)
    @color = color
    @game = game
    @goes_first = @color == Game::WHITE
    @turns_taken = 0
    @input = Input.new(self, @game)
  end

  def get_move
    @input.get_move
  end

  def get_all_possible_moves
    possible_moves = []
    @pieces.each do |piece|
      next if piece.is_captured || piece.promoted_to
      piece_moves = piece.get_all_possible_moves
      piece_moves.each do |move|
        possible_moves.push({piece:, move:})
      end
    end
    possible_moves
  end
end
