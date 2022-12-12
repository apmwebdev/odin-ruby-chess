# frozen_string_literal: true

require_relative "game"

class Output
  attr_reader :game, :rows

  def initialize(game)
    @game = game
    @rows = []
  end

  def clear_screen
    (system "clear") || (system "cls")
  end

  def get_rows
    @game.board.squares.each_slice(8) { |slice| @rows.push(slice) }
  end

  def render_board
    @rows = []
    get_rows
    file_label_row = "    #{Board::FILES.join("    ")}"
    render_rows = []
    @rows.reverse.each_with_index do |row, index|
      render_rows.concat(render_row(row, index))
    end
    puts file_label_row
    render_rows.each { |row| puts row }
    puts file_label_row
  end

  def render_row(row, row_index)
    dark_first = row[0].color == "dark"
    row_top = "  "
    if dark_first
      4.times { row_top += "#{block("dark", " ")}#{block("light", " ")}" }
    else
      4.times { row_top += "#{block("light", " ")}#{block("dark", " ")}" }
    end
    rank_label = (8 - row_index).to_s
    row_middle = "#{rank_label} "
    row.each_with_index do |square, index|
      piece = if square.piece
        get_piece(square.piece.name, square.piece.color)
      else
        " "
      end
      row_middle += if index % 2 == 0
        dark_first ? block("dark", piece) : block("light", piece)
      else
        dark_first ? block("light", piece) : block("dark", piece)
      end
    end
    row_middle += " #{rank_label}"
    [row_top, row_middle, row_top]
  end

  def get_piece(name, color)
    piece = case name.downcase
    when "king"
      (color == Game::WHITE) ? "\u2654" : "\u265a"
    when "queen"
      (color == Game::WHITE) ? "\u2655" : "\u265b"
    when "rook"
      (color == Game::WHITE) ? "\u2656" : "\u265c"
    when "bishop"
      (color == Game::WHITE) ? "\u2657" : "\u265d"
    when "knight"
      (color == Game::WHITE) ? "\u2658" : "\u265e"
    when "pawn"
      (color == Game::WHITE) ? "\u2659" : "\u265f"
    else
      ""
    end
    (color == Game::WHITE) ? "\e[97m#{piece}" : "\e[30m#{piece}"
  end

  def block(color, char)
    if color == "light_yellow"
      "\e[103m  #{char}  \e[0m"
    elsif color == "dark_gray"
      "\e[100m  #{char}  \e[0m"
    elsif color == "dark"
      "\e[41m  #{char}  \e[0m"
    elsif color == "green"
      "\e[42m  #{char}  \e[0m"
    elsif color == "light"
      "\e[43m  #{char}  \e[0m"
    end
  end
end
