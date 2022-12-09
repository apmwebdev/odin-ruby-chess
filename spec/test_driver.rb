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
end

def get_all_king_moves
  game = Game.new
  game.start_game

  puts "King:"
  w_king = game.pieces.get_piece_at("e1")
  w_king.move_to("e4")
  show_all_moves(w_king)
  puts "at e5:"
  w_king.move_to("e5")
  show_all_moves(w_king)
end

def get_all_knight_moves
  game = Game.new
  game.start_game

  b1_knight = game.pieces.get_piece_at("b1")
  show_all_moves(b1_knight)
  b1_knight.move_to("e5")
  puts "at e5:"
  show_all_moves(b1_knight)
end

def get_all_pawn_moves
  game = Game.new
  game.start_game

  e2_pawn = game.pieces.get_piece_at("e2")
  d7 = game.pieces.get_piece_at("d7")
  d7.move_to("f3")
  show_all_moves(e2_pawn)
  e2_pawn.move_to("e4")
  show_all_moves(e2_pawn)
end

def show_all_moves(piece)
  piece.get_all_possible_moves.each do |square|
    puts square.id
  end
end

get_all_king_moves