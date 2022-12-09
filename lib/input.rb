# frozen_string_literal: true

require_relative "game"
require_relative "board"

class Input
  attr_reader :player, :game

  def initialize(player, game)
    @player = player
    @game = game
  end

  def get_move
    loop do
      input = gets.chomp
      input.downcase!
      if valid_input?(input)
        valid_move = valid_move?(input)
        return valid_move if valid_move
      end
      puts "Input error! Please enter a valid move"
    end
  end

  def valid_input?(input)
    return false if input.length != 4
    return false unless input.match?(/^[a-h][1-8][a-h][1-8]$/)
    return false if input[0..1] == input[2..3]
    true
  end

  def valid_move?(input)
    start_coord = [input[0], input[1].to_i]
    end_coord = [input[2], input[3].to_i]
    piece = @game.pieces.get_piece_at(start_coord)
    unless piece
      puts "No piece at #{start_coord.join("")}"
      return false
    end
    unless @player.color == piece.color
      puts "You don't control this piece"
      return false
    end
    unless piece.valid_move?(end_coord)
      puts "This piece can't move there"
      return false
    end
    if would_be_in_check?(piece, end_coord)
      puts "You must defend your king"
      return false
    end
    [start_coord, end_coord]
  end

  def would_be_in_check?(piece, end_coord)
    potential_move = piece.move_to(end_coord)
    would_be_in_check = @game.player_is_in_check?(@player)
    piece.undo_move(potential_move)
    would_be_in_check
  end
end
