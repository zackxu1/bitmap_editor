# frozen_string_literal: true
class Bitmap

  class InvalidSizeError < RuntimeError; end
  class InvalidValueError < RuntimeError; end
  class InvalidIndexError < RuntimeError; end

  WHITE = 'O'
  MAX_SIZE = 250
  SIZE_RANGE = 1..MAX_SIZE
  VALID_VALUES = 'A'..'Z'
  VALID_VALUE = /[A-Z]/

  attr_reader :col_size, :row_size

  def initialize(row_size:, col_size:)
    validate_size(row_size, col_size)
    @row_size, @col_size = row_size, col_size
    clear
  end

  def clear
    @data = Array.new(col_size) { row }
  end

  def update_cell(value, row:, col:)
    validate_value(value)
    col, row = validate_col(col), validate_row(row)
    @data[row][col] = value
  end

  def update_row(value, row:, col1:, col2:)
    validate_value(value)
    row = validate_row(row)
    col1, col2 = validate_col(col1, col2)
    @data[row][col1..col2] = value * (col1..col2).size
  end

  def update_col(value, col:, row1:, row2:)
    validate_value(value)
    col = validate_col(col)
    row1, row2 = validate_row(row1, row2)
    @data[row1..row2].each { |row| row[col] = value }
  end

  def to_s
    @data * "\n" + "\n"
  end

  def bucket_fill(value, col:, row:)
    validate_value(value)
    return unless cell_value(row: row, col: col) == WHITE
    update_cell(value, row: row, col: col)
    neighbouring_cells(row: row, col: col).each do |cell|
      bucket_fill(value, row: cell[:row], col: cell[:col])
    end
  end

  private

  def row
    WHITE * row_size
  end

  def validate_value(value)
    unless VALID_VALUES.cover?(value)
      raise InvalidValueError, "Value #{value} not in #{VALID_VALUES}"
    end
  end

  def validate_size(*sizes)
    unless sizes.all? { |s| SIZE_RANGE.cover?(s) }
      raise InvalidSizeError,
            "Bitmap size #{sizes * 'x'} exceeds limit #{MAX_SIZE}x#{MAX_SIZE}"
    end
  end

  def validate_row(*indices)
    validate_index(indices, col_size)
  end

  def validate_col(*indices)
    validate_index(indices, row_size)
  end

  def validate_index(indices, limit)
    unless indices.all? { |i| (1..limit).cover?(i) }
      raise InvalidIndexError, "Indices #{indices} must not exceed #{limit}"
    end
    indices.map! { |i| i - 1 }
    indices.size > 1 ? indices : indices.first
  end

  def cell_value(row:, col:)
    row, col = validate_row(row), validate_col(col)
    @data[row][col]
  end

  def neighbouring_cells(row:, col:)
    four_neighbouring_cells(row: row, col: col).select do |cell|
      valid_cell?(cell)
    end
  end

  def four_neighbouring_cells(row:, col:)
    [
      { row: row - 1, col: col },
      { row: row + 1, col: col },
      { row: row,     col: col - 1 },
      { row: row,     col: col + 1 }
    ]
  end

  def valid_cell?(cell)
    (1..col_size).cover?(cell[:row]) && (1..row_size).cover?(cell[:col])
  end
end
