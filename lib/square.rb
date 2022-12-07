# frozen_string_literal: true

class Square
  attr_accessor :piece, :color, :up, :down, :left, :right, :up_left, :up_right,
    :down_left, :down_right
  attr_reader :id

  FILES = %w[a b c d e f g h]
  RANKS = (1..8).to_a

  def initialize(coordinate)
    @id = coordinate
  end

  def determine_relationship_to(coord)
    file = @id[0]
    rank = @id[1]
    new_file = coord[0]
    new_rank = coord[1]
    file_change = (FILES.find_index(file) - FILES.find_index(new_file)).abs
    rank_change = (rank - new_rank).abs

    is_adjacent_to = file_change <= 1 && rank_change <= 1
    is_diagonal_to = file_change == rank_change
    is_orthogonal_to = file_change.zero? || rank_change.zero?
    knight_can_move_to = [file_change, rank_change].sort == [1, 2]

    {is_adjacent_to:, is_diagonal_to:, is_orthogonal_to:, knight_can_move_to:}
  end

  def is_adjacent_to?(coord)
    determine_relationship_to(coord)[:is_adjacent_to]
  end

  def is_diagonal_to?(coord)
    determine_relationship_to(coord)[:is_diagonal_to]
  end

  def is_orthogonal_to?(coord)
    determine_relationship_to(coord)[:is_orthogonal_to]
  end

  def knight_can_move_to?(coord)
    determine_relationship_to(coord)[:knight_can_move_to]
  end

  def is_diagonally_adjacent_to?(coord)
    result = determine_relationship_to(coord)
    result[:is_adjacent_to] && result[:is_diagonal_to]
  end

  def is_orthogonally_adjacent_to?(coord)
    result = determine_relationship_to(coord)
    result[:is_adjacent_to] && result[:is_orthogonal_to]
  end

  def route_is_open_to?(coord)
    route_squares = get_squares_between(coord)
    route_squares.each do |square|
      return false unless square.piece.nil?
    end
    true
  end

  def get_squares_between(coord)
    return_arr = []
    file = @id[0]
    file_i = FILES.find_index(file)
    rank = @id[1]
    new_file = coord[0]
    new_file_i = FILES.find_index(new_file)
    new_rank = coord[1]
    coords = []
    if file == new_file
      (rank...new_rank).each do |rank_in_between|
        coords.push([file, rank_in_between])
      end
    elsif rank == new_rank
      (file...new_file).each do |file_in_between|
        coords.push([file_in_between, rank])
      end
    else
      coords = get_squares_along_diag_path(coord)
    end
    coords.each do |path_coord|
      return_arr.push(@squares.find { |square| square.id == path_coord })
    end
    return_arr
  end

  def get_squares_along_diag_path(coord)
    coords = []
    file = @id[0]
    file_i = FILES.find_index(file)
    rank = @id[1]
    new_file = coord[0]
    new_file_i = FILES.find_index(new_file)
    new_rank = coord[1]
    if file_i > new_file_i && rank > new_rank
      loop do
        file_i -= 1
        rank -= 1
        break if rank == new_rank
        coords.push([FILES[file_i], rank])
      end
    elsif file_i > new_file_i && rank < new_rank
      loop do
        file_i -= 1
        rank += 1
        break if rank == new_rank
        coords.push([FILES[file_i], rank])
      end
    elsif file_i < new_file_i && rank > new_rank
      loop do
        file_i += 1
        rank -= 1
        break if rank == new_rank
        coords.push([FILES[file_i], rank])
      end
    elsif file_i < new_file_i && rank < new_rank
      loop do
        file_i += 1
        rank += 1
        break if rank == new_rank
        coords.push([FILES[file_i], rank])
      end
    end
    coords
  end
end