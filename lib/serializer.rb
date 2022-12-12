# frozen_string_literal: true

require "json"

class Serializer
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def serialize_game_data
    squares = @game.board.squares.map { |square| square.serialize }
    moves = @game.move_log.map { |move| move.serialize }
    {
      squares:, moves:,
      players: {
        white: @game.white_player.turns_taken,
        black: @game.black_player.turns_taken
      }
    }
  end

  def save_game
    continue = "You may continue with the game. Enter your move:"
    move_log = @game.move_log
    if move_log.empty?
      return puts "Save error: No data to save"
    end

    file_name_input = ""
    loop do
      puts "Enter a filename with no file extension (c to cancel):"
      file_name_input = gets.chomp
      if file_name_input == ""
        puts "Save error: Invalid save file name"
      elsif file_name_input == "c"
        puts "Save canceled"
        puts continue
        return
      else
        break
      end
    end

    save_data = move_log.last.game_state_after.to_json
    file_name = "saved_games/#{file_name_input}.json"
    if File.exist?(file_name)
      puts_str = "A file already exists with this name. Overwrite? "
      puts_str += "(y or n, c to cancel)"
      puts puts_str
      answer = gets.chomp
      if answer == "y"
        File.truncate(file_name, 0)
        File.open(file_name, "w") { |file| file.puts save_data }
        puts "Game saved!"
        puts continue
      elsif answer == "n"
        save_game
      elsif answer == "c"
        puts "Save canceled"
        puts continue
      else
        puts "Save error: Invalid selection"
        save_game
      end
    else
      File.open(file_name, "w") { |file| file.puts save_data }
      puts "Game saved!"
      puts continue
    end
  end

  def load_game
    puts "load_game placeholder"
  end
end
