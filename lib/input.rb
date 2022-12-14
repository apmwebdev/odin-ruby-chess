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
      if input == "s" || input == "l"
        return input
      else
        valid_move = valid_move_input?(input)
        return valid_move if valid_move
      end
      puts "Input error! Please enter a valid move"
    end
  end

  def valid_move_input?(input)
    unless input.length == 4
      puts "Input should be 4 characters (start coordinate + end coordinate)"
      return false
    end
    unless input.match?(/^[a-h][1-8][a-h][1-8]$/)
      puts "Invalid input format. Input should be start + end coordinates"
      return false
    end
    if input[0..1] == input[2..3]
      puts "Start and end coordinates must be different"
      return false
    end
    start_coord = input[0..1]
    end_coord = input[2..3]
    piece = @game.pieces.get_piece_at(start_coord)
    unless piece
      puts "No piece at #{start_coord}"
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

  def get_promotion_choice
    loop do
      puts_str = "Choose promotion: Enter q for queen, r for rook, b for "
      puts_str += "bishop, or n for knight."
      puts puts_str
      input = gets.chomp
      input.downcase!
      return input if valid_promotion_input?(input)

      puts "Input error! Please enter a valid promotion choice"
    end
  end

  def valid_promotion_input?(input)
    /^[qrbn]$/.match?(input)
  end

  def would_be_in_check?(piece, end_coord)
    potential_move = piece.move_to(end_coord)
    would_be_in_check = @game.player_is_in_check?(@player)
    potential_move.undo
    would_be_in_check
  end
end
