require 'rails_helper'

RSpec.describe Traders::RegisterService do
  describe '.call' do
    let(:params) { { name: 'Test Trader', email: 'test@example.com', balance: 100.0 } }

    context 'with valid parameters' do
      it 'registers a new trader' do
        expect do
          result = described_class.call(**params)
          expect(result.success?).to be true
          expect(result.data).to be_a(Trader)
          expect(result.data.email).to eq('test@example.com')
        end.to change(Trader, :count).by(1)
      end

      it 'creates trader transaction for the initial balance' do
        result = described_class.call(**params)
        expect(TraderTransaction.where(trader_id: result.data.id, amount: 100.0).exists?).to be true
      end
    end

    context 'when the email already exists' do
      before do
        Trader.create!(name: 'Existing', email: 'test@example.com')
      end

      it 'returns a failure result with an error message' do
        expect do
          result = described_class.call(**params)
          expect(result.success?).to be false
          expect(result.errors).to include('Email has already been taken')
        end.not_to change(Trader, :count)
      end
    end

    context 'when validation fails' do
      before do
        allow_any_instance_of(Trader).to receive(:save!).and_raise(
          ActiveRecord::RecordInvalid.new(Trader.new.tap { |t| t.errors.add(:name, "can't be blank") })
        )
      end

      it 'returns a failed result with validation errors' do
        result = described_class.call(**params)
        expect(result.success?).to be false
        expect(result.error_type).to eq(:validation_error)
        expect(result.errors).to include("Name can't be blank")
      end
    end
  end
end
