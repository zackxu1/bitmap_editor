# frozen_string_literal: true
require_relative 'bitmap'

class CommandInterpreter

  class InvalidInputError < RuntimeError; end
  class BitmapInitError < RuntimeError; end

  VALIDATION = {
    I: /\AI +\d+ +\d+\Z/,
    L: /\AL +\d+ +\d+ +#{Bitmap::VALID_VALUE}\Z/,
    V: /\AV +\d+ +\d+ +\d+ +#{Bitmap::VALID_VALUE}\Z/,
    H: /\AH +\d+ +\d+ +\d+ +#{Bitmap::VALID_VALUE}\Z/,
    S: /\AS\Z/,
    C: /\AC\Z/
  }

  def initialize(commands)
    @commands = commands.map(&:strip).delete_if(&:empty?)
    validate_input if @commands.any?
  end

  def execute
    @commands.each do |command|
      tokens = command.split
      code = tokens.shift

      case code
        when 'I' then new_bitmap(tokens)
        when 'L' then update_cell(tokens)
        when 'V' then update_col(tokens)
        when 'H' then update_row(tokens)
        when 'S' then show_bitmap
        when 'C' then clear_bitmap
      end
    end
  end

  private

  def validate_input
    @commands.each { |command| validate_command(command) }
    validate_bitmap_init
  end

  def validate_command(command)
    if VALIDATION.values.none? { |regex| command =~ regex }
      raise InvalidInputError, "Invalid command: #{command}"
    end
  end

  def validate_bitmap_init
    if @commands.first !~ VALIDATION[:I]
      raise BitmapInitError, "Bitmap must be initialised"
    end
  end

  def new_bitmap(tokens)
    tokens.map!(&:to_i)
    @bitmap = Bitmap.new(row_size: tokens[0], col_size: tokens[1])
  end

  def clear_bitmap
    @bitmap.clear
  end

  def update_cell(tokens)
    value = tokens.pop
    tokens.map!(&:to_i)
    @bitmap.update_cell(value, col: tokens[0], row: tokens[1])
  end

  def update_row(tokens)
    value = tokens.pop
    tokens.map!(&:to_i)
    @bitmap.update_row(value, col1: tokens[0], col2: tokens[1], row: tokens[2])
  end

  def update_col(tokens)
    value = tokens.pop
    tokens.map!(&:to_i)
    @bitmap.update_col(value, col: tokens[0], row1: tokens[1], row2: tokens[2])
  end

  def show_bitmap
    print @bitmap.to_s
  end
end
