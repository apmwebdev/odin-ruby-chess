# odin-ruby-chess

## Game class
- register players
- drive turns
- determine check, checkmate
- Help determine whether a move is valid
- Deal with pawns making it to back rank
- Deal with castling?
- collect player input?

## Game_Output class
- render board and pieces
- collect player input?

## Input class?
Have separate class for input? That way basic validation of moves can be done in this class.
- Use ICCF numeric notation? Regular notation? Expanded notation?

## Piece class
Parent class for different pieces. Some things to have:
- Name of piece
- Valid moves
- Whether movement is "extendable" (they can move until they're blocked)
- Whether piece can "jump" over blockers (i.e., the knight)
- Track whether piece has moved or not? (Relevant for castling, pawns)
- color (set at beginning of game)
- 