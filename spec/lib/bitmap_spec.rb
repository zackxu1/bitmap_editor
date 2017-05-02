require 'spec_helper'

RSpec.describe Bitmap do
  let(:matrix) do
    described_class.new(row_size: 4, col_size: 6)
  end

  let(:initial_state) do
     <<~EOS
      OOOO
      OOOO
      OOOO
      OOOO
      OOOO
      OOOO
    EOS
  end

  context 'valid input' do
    describe '#new' do
      specify { expect(matrix).to be_a Bitmap }
    end

    describe '#col_size' do
      specify { expect(matrix.col_size).to eq(6) }
    end

    describe '#row_size' do
      specify { expect(matrix.row_size).to eq(4) }
    end

    describe '#to_s' do
      it 'contains the initial state' do
        expect(matrix.to_s).to eq initial_state
      end
    end

    describe '#update_cell' do
      it 'updates a cell correctly' do
        matrix.update_cell('Z', row: 4, col: 2)
        expect(matrix.to_s).to eq <<~EOS
          OOOO
          OOOO
          OOOO
          OZOO
          OOOO
          OOOO
        EOS
      end
    end

    describe '#update_row' do
      it 'updates a row correctly' do
        matrix.update_row('Z', row: 2, col1: 1, col2: 3)
        expect(matrix.to_s).to eq <<~EOS
          OOOO
          ZZZO
          OOOO
          OOOO
          OOOO
          OOOO
        EOS
      end
    end

    describe '#update_col' do
      it 'updates a column correctly' do
        matrix.update_col('Z', col: 2, row1: 3, row2: 6)
        expect(matrix.to_s).to eq <<~EOS
          OOOO
          OOOO
          OZOO
          OZOO
          OZOO
          OZOO
        EOS
      end
    end

    describe '#clear' do
      before do
        matrix.update_col('Z', col: 2, row1: 3, row2: 6)
        matrix.clear
      end

      it 'clears it to the initial state' do
        expect(matrix.to_s).to eq initial_state
      end
    end
  end

  context 'invalid input' do
    describe '#new' do
      context 'when size is too small' do
        it 'raises InvalidSizeError' do
          expect {
            described_class.new(row_size: 0, col_size: 5)
          }.to raise_error(described_class::InvalidSizeError)
        end
      end

      context 'when size is too big' do
        it 'raises InvalidSizeError' do
          expect {
            described_class.new(row_size: 10, col_size: 305)
          }.to raise_error(described_class::InvalidSizeError)
        end
      end
    end

    describe '#update_cell' do
      context 'when row is out of bound' do
        it 'raises InvalidIndexError' do
          expect {
            matrix.update_cell('Z', row: 5, col: 5)
          }.to raise_error(described_class::InvalidIndexError)
        end
      end

      context 'when col is out of bound' do
        it 'raises InvalidIndexError' do
          expect {
            matrix.update_cell('Z', row: 4, col: 15)
          }.to raise_error(described_class::InvalidIndexError)
        end
      end

      context 'when value is invalid' do
        it 'raises InvalidValueError' do
          expect {
            matrix.update_cell('-', row: 4, col: 6)
          }.to raise_error(described_class::InvalidValueError)
        end
      end
    end

    describe '#update_row' do
      context 'when row is out of bound' do
        it 'raises InvalidIndexError' do
          expect {
            matrix.update_row('Z', row: 10, col1: 1, col2: 3)
          }.to raise_error(described_class::InvalidIndexError)
        end
      end

      context 'when col is out of bound' do
        it 'raises InvalidIndexError' do
          expect {
            matrix.update_row('Z', row: 3, col1: 10, col2: 15)
          }.to raise_error(described_class::InvalidIndexError)
        end
      end

      context 'when value is invalid' do
        it 'raises InvalidValueError' do
          expect {
            matrix.update_row('(', row: 4, col1: 1, col2: 3)
          }.to raise_error(described_class::InvalidValueError)
        end
      end
    end

    describe '#update_col' do
      context 'when col is out of bound' do
        it 'raises InvalidIndexError' do
          expect {
            matrix.update_col('Z', col: 12, row1: 2, row2: 3)
          }.to raise_error(described_class::InvalidIndexError)
        end
      end

      context 'when row is out of bound' do
        it 'raises InvalidIndexError' do
          expect {
            matrix.update_col('Z', col: 4, row1: 2, row2: 7)
          }.to raise_error(described_class::InvalidIndexError)
        end
      end

      context 'when value is invalid' do
        it 'raises InvalidValueError' do
          expect {
            matrix.update_col('.', col: 4, row1: 1, row2: 1)
          }.to raise_error(described_class::InvalidValueError)
        end
      end
    end
  end
end
