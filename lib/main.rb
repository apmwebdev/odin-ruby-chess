require_relative "game"
require_relative "board"
require_relative "square"
require_relative "piece"
require_relative "piece/bishop"
require_relative "piece/king"
require_relative "piece/knight"
require_relative "piece/pawn"
require_relative "piece/queen"
require_relative "piece/rook"

game = Game.new
game.start_game
game.board.squares.each do |square|
  str = "#{square.id}: "
  str += square.piece.name if square.piece
  p str
end