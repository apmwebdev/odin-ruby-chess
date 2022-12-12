require_relative "board"
require_relative "game"
require_relative "input"
require_relative "move"
require_relative "output"
require_relative "piece"
require_relative "pieces"
require_relative "player"
require_relative "square"
require_relative "piece/bishop"
require_relative "piece/king"
require_relative "piece/knight"
require_relative "piece/pawn"
require_relative "piece/queen"
require_relative "piece/rook"

game = Game.new
game.start_game

# TODO:
# Add threefold repetition draw rule?
# Add fifty-move draw rule?
# Add dead position draw rule?
# Add save support
