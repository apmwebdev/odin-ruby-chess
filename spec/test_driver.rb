# frozen_string_literal: true

require_relative "../lib/game"
require_relative "../lib/board"
require_relative "../lib/square"
require_relative "../lib/input"
require_relative "../lib/piece"
require_relative "../lib/pieces"
require_relative "../lib/player"
require_relative "../lib/piece/bishop"
require_relative "../lib/piece/king"
require_relative "../lib/piece/knight"
require_relative "../lib/piece/pawn"
require_relative "../lib/piece/queen"
require_relative "../lib/piece/rook"

def board_test
  game = Game.new
  game.start_game
  game.board.squares.each do |square|
    piece = square.piece
    puts_str = "#{square.id} #{square.coord} "
    puts_str += "#{piece.name} #{piece.color}" if piece
    puts puts_str
  end
end

def pieces_test
  game = Game.new
  game.start_game
  game.pieces.white_pieces.each do |piece|
    square = piece.square
    puts "#{piece.color} #{piece.name}: #{square.id}, #{square.coord}"
  end
  game.pieces.black_pieces.each do |piece|
    square = piece.square
    puts "#{piece.color} #{piece.name}: #{square.id}, #{square.coord}"
  end
end

board_test

