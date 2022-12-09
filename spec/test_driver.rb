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

def get_all_possible_moves_basic_test
  game = Game.new
  game.start_game

  puts "Rook:"
  a1_rook = game.pieces.get_piece_at("a1")
  a1_rook.move_to("d4")
  rook_moves = a1_rook.get_all_possible_moves
  rook_moves.each do |square|
    puts square.id
  end
  a1_rook.move_to("a1")

  puts "Bishop:"
  c1_bishop = game.pieces.get_piece_at("c1")
  c1_bishop.move_to("c4")
  c1_bishop.get_all_possible_moves.each do |square|
    puts square.id
  end
  c1_bishop.move_to("c1")

  puts "Queen:"
  w_queen = game.pieces.get_piece_at("d1")
  w_queen.move_to("d4")
  w_queen.get_all_possible_moves.each do |square|
    puts square.id
  end
  w_queen.move_to("d1")

  puts "King:"
  w_king = game.pieces.get_piece_at("e1")
  w_king.move_to("e4")
  w_king.get_all_possible_moves.each do |square|
    puts square.id
  end
  puts w_king.valid_move?("d4")
  puts w_king.valid_move?("a6")
end

get_all_possible_moves_basic_test
