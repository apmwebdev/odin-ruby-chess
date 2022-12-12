# frozen_string_literal: true

class Board
  attr_accessor :squares

  FILES = ("a".."h").to_a
  RANKS = (1..8).to_a
  DARK_FIRST_FILES = %w[a c e g]
  LIGHT_FIRST_FILES = %w[b d f h]

  def initialize
    @squares = []
    create_board
  end

  def create_board
    ids = RANKS.product(FILES)
    ids.each do |id|
      file_num = id[1].bytes[0] - 97
      rank_num = id[0] - 1
      coord = [file_num, rank_num]
      @squares.push(Square.new(id.reverse.join(""), coord, self))
    end
    initialize_square_data
  end

  def get_square(query)
    if query.is_a?(Array)
      @squares.find { |square| square.coord == query }
    else
      @squares.find { |square| square.id == query }
    end
  end

  def initialize_square_data
    @squares.each do |square|
      set_square_color(square)
      link_adjacent_squares(square)
    end
  end

  def set_square_color(square)
    square.color = if (DARK_FIRST_FILES.include?(square.id[0]) &&
      square.id[1].to_i % 2 == 1) ||
        (LIGHT_FIRST_FILES.include?(square.id[0]) && square.id[1].to_i % 2 == 0)
      "dark"
    else
      "light"
    end
  end

  # def determine_square_relationship(start_coord, end_coord)
  #   file = start_coord[0]
  #   rank = start_coord[1]
  #   new_file = end_coord[0]
  #   new_rank = end_coord[1]
  #   file_change = (file - new_file).abs
  #   rank_change = (rank - new_rank).abs
  #
  #   is_adjacent_to = file_change <= 1 && rank_change <= 1
  #   is_diagonal_to = file_change == rank_change
  #   is_orthogonal_to = file_change.zero? || rank_change.zero?
  #   knight_can_move_to = [file_change, rank_change].sort == [1, 2]
  #   {is_adjacent_to:, is_diagonal_to:, is_orthogonal_to:, knight_can_move_to:}
  # end
  #
  # def is_adjacent_to?(start_coord, end_coord)
  #   determine_square_relationship(start_coord, end_coord)[:is_adjacent_to]
  # end
  #
  # def is_diagonal_to?(start_coord, end_coord)
  #   determine_square_relationship(start_coord, end_coord)[:is_diagonal_to]
  # end
  #
  # def is_orthogonal_to?(start_coord, end_coord)
  #   determine_square_relationship(start_coord, end_coord)[:is_orthogonal_to]
  # end
  #
  # def knight_can_move_to?(start_coord, end_coord)
  #   determine_square_relationship(start_coord, end_coord)[:knight_can_move_to]
  # end
  #
  # def route_is_open_to?(start_coord, end_coord)
  #   route_squares = get_squares_between(start_coord, end_coord)
  #   route_squares.each do |square|
  #     return false unless square.piece.nil?
  #   end
  #   true
  # end
  #
  # def get_squares_between(start_coord, end_coord)
  #   return_arr = []
  #   file = start_coord[0]
  #   rank = start_coord[1]
  #   new_file = end_coord[0]
  #   new_rank = end_coord[1]
  #   coords = if rank == new_rank || file == new_file
  #     get_squares_along_orthog_path(start_coord, end_coord)
  #   else
  #     get_squares_along_diag_path(start_coord, end_coord)
  #   end
  #   coords.each do |path_coord|
  #     return_arr.push(@squares.find { |square| square.coord == path_coord })
  #   end
  #   return_arr
  # end
  #
  # def get_squares_along_orthog_path(start_coord, end_coord)
  #   file = start_coord[0]
  #   rank = start_coord[1]
  #   new_file = end_coord[0]
  #   new_rank = end_coord[1]
  #   coords = []
  #   if file == new_file
  #     (rank...new_rank).each do |rank_in_between|
  #       coords.push([file, rank_in_between])
  #     end
  #   else
  #     (file...new_file).each do |file_in_between|
  #       coords.push([file_in_between, rank])
  #     end
  #   end
  #   coords
  # end
  #
  # def get_squares_along_diag_path(start_coord, end_coord)
  #   coords = []
  #   file = start_coord[0]
  #   rank = start_coord[1]
  #   new_file = end_coord[0]
  #   new_rank = end_coord[1]
  #   loop do
  #     file = (file > new_file) ? file - 1 : file + 1
  #     rank = (rank > new_rank) ? rank - 1 : rank + 1
  #     break if rank == new_rank
  #     coords.push([file, rank])
  #   end
  #   coords
  # end

  def link_adjacent_squares(square)
    file = square.coord[0]
    rank = square.coord[1]
    square.up = get_square([file, rank + 1])
    square.down = get_square([file, rank - 1])
    square.left = get_square([file - 1, rank])
    square.right = get_square([file + 1, rank])
    square.up_left = get_square([file - 1, rank + 1])
    square.up_right = get_square([file + 1, rank + 1])
    square.down_left = get_square([file - 1, rank - 1])
    square.down_right = get_square([file + 1, rank - 1])
  end
end
