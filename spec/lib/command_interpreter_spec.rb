require 'spec_helper'

RSpec.describe CommandInterpreter do

  shared_examples_for :valid_input do |interpreter|
    describe '#new' do
      specify { expect(interpreter).to be_an CommandInterpreter }
    end

    describe '#execute' do
      specify { expect { interpreter.execute }.not_to raise_error }
    end
  end

  include_examples :valid_input, described_class.new(['I 5 6'])

  describe 'command I' do
    let(:interpreter) do
      described_class.new(['I 5 6'])
    end

    it 'initializes a bitmap' do
      expect(Bitmap).to receive(:new).with(row_size: 5, col_size: 6)
      interpreter.execute
    end
  end

  describe 'command C' do
    let(:interpreter) do
      described_class.new(['I 5 6', 'C'])
    end

    it 'clears the bitmap' do
      allow_any_instance_of(Bitmap).to receive(:clear)
      interpreter.execute
    end
  end

  describe 'command S' do
    let(:interpreter) do
      described_class.new(['I 5 6', 'S'])
    end

    it 'outputs bitmap to stdout' do
      allow_any_instance_of(Bitmap).to receive(:to_s).and_return('xxx')
      expect { interpreter.execute }.to output('xxx').to_stdout
    end
  end

  describe 'command L' do
    let(:interpreter) do
      described_class.new(['I 5 6', 'L 1 3 A'])
    end

    it 'updates a single cell in bitmap' do
      expect_any_instance_of(Bitmap).to receive(:update_cell).with(
        'A', col: 1, row: 3)
      interpreter.execute
    end
  end

  describe 'command H' do
    let(:interpreter) do
      described_class.new(['I 5 6', 'H 3 5 2 Z'])
    end

    it 'updates a row of cells in bitmap' do
      expect_any_instance_of(Bitmap).to receive(:update_row).with(
        'Z', col1: 3, col2: 5, row: 2)
      interpreter.execute
    end
  end

  describe 'command V' do
    let(:interpreter) do
      described_class.new(['I 5 6', 'V 2 3 6 W'])
    end

    it 'updates a column of cells in bitmap' do
      expect_any_instance_of(Bitmap).to receive(:update_col).with(
        'W', col: 2, row1: 3, row2: 6)
      interpreter.execute
    end
  end

  context 'validation' do
    context 'empty input' do
      include_examples :valid_input, described_class.new([])
    end

    context 'input contains white spaces' do
      include_examples :valid_input, described_class.new(
        ['', '  I  5 6 ',' C','L 2 3   W '])
    end

    context 'input contains unknown command' do
      it 'raises InvalidInputError' do
        expect {
          described_class.new(['I 5 6', 'Q 1'])
        }.to raise_error(described_class::InvalidInputError)
      end
    end

    context 'input fails to initialize bitmap' do
      it 'raises BitmapInitError' do
        expect {
          described_class.new(['S'])
        }.to raise_error(described_class::BitmapInitError)
      end
    end

    context 'input contains the wrong number of parameters' do
      it 'raises InvalidInputError' do
        expect {
          described_class.new(['I 5 6', 'L 2 3 A Z'])
        }.to raise_error(described_class::InvalidInputError)
      end
    end

    context 'input contains the wrong parameter type' do
      it 'raises InvalidInputError' do
        expect {
          described_class.new(['I 5 6', 'L 2 3 a'])
        }.to raise_error(described_class::InvalidInputError)
      end
    end
  end
end
