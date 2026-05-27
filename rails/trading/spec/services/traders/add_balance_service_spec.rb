require 'rails_helper'

RSpec.describe Traders::AddBalanceService do
  describe '.call' do
    let!(:trader) { Trader.create!(name: 'Test Trader', email: 'test@example.com', balance: 50.0) }

    context 'when the trader exists' do
      it "adds the amount to the trader's balance" do
        result = described_class.call(email: 'test@example.com', amount: 100.5)
        expect(result.success?).to be true
        expect(result.data.reload.balance).to eq(150.5)
      end

      it 'calls Trader.increment_counter to perform an atomic update' do
        expect(Trader).to receive(:increment_counter).with(:balance, trader.id, by: 100.5).and_call_original
        described_class.call(email: 'test@example.com', amount: 100.5)
      end

      it 'creates trader transaction for the balance change' do
        expect { described_class.call(email: 'test@example.com', amount: 100.5) }.to change {
          TraderTransaction.where(trader_id: trader.id, amount: 100.5).count
        }.by(1)
      end
    end

    context 'when the trader does not exist' do
      it 'returns a failed result with error_type :not_found' do
        result = described_class.call(email: 'non.existent@example.com', amount: 10.0)
        expect(result.success?).to be false
        expect(result.error_type).to eq(:not_found)
        expect(result.errors).to include('Trader not found')
      end
    end
  end
end
