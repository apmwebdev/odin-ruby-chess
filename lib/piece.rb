# frozen_string_literal: true

class Piece
  attr_accessor :has_moved, :is_captured, :square, :game, :player, :promoted_to,
    :promoted_from
  attr_reader :moves_orthogonally, :moves_diagonally, :is_rider, :is_leaper,
    :name, :color

  def initialize(color, square)
    @name = self.class.name.split("::").last
    @color = color
    @square = square
    @is_captured = false
  end

  def valid_move?(end_coord)
    end_square = @game.board.get_square(end_coord)
    get_all_possible_moves.include?(end_square)
  end

  def get_all_possible_moves
    directions = []
    directions.concat(%w[up down left right]) if @moves_orthogonally
    diagonal_moves = %w[up_left up_right down_left down_right]
    directions.concat(diagonal_moves) if @moves_diagonally
    possible_moves = []
    directions.each do |direction|
      if @is_rider
        results = get_moves_in_direction(direction, @square)
        possible_moves.concat(results) if results
      else
        adj_square = @square.public_send(direction)
        unless adj_square.nil? ||
            (adj_square.piece && adj_square.piece.color == @color)
          possible_moves.push(adj_square)
        end
      end
    end
    possible_moves
  end

  def get_moves_in_direction(direction, start_square, results = [])
    new_square = start_square.public_send(direction)
    return if new_square.nil?
    return if new_square.piece && new_square.piece.color == @color
    if new_square.piece && new_square.piece.color != @color
      results.push(new_square)
    elsif new_square.piece.nil?
      results.push(new_square)
      get_moves_in_direction(direction, new_square, results)
    end
    results
  end

  def move_to(new_position)
    has_moved_prior = @has_moved
    start_square = @square
    end_square = @game.board.get_square(new_position)
    captured_piece = end_square.piece

    move = Move.new(self, start_square, end_square, "normal", @game)
    move.has_moved_prior = has_moved_prior
    move.captured_piece = captured_piece
    move.do_move

    move
  end

  def serialize
    {
      name: @name,
      color: @color,
      has_moved: @has_moved
    }
  end

  def to_s
    return_str = "Piece: name: #{@name}, color: #{@color}, "
    return_str += "has_moved: #{@has_moved}, square: #{@square.id}"
    return_str
  end
end
