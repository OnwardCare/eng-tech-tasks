require 'rails_helper'
RSpec.describe Trader, type: :model do
  let(:trader) { Trader.create!(name: 'Test Trader', email: 'test@example.com', balance: 999) }
  describe '#balance' do
    context 'when the new feature is enabled' do
      around(:each) do |example|
        ENV['TRADER_TRANSACTIONS_BALANCE'] = 'true'
        example.run
      ensure
        ENV['TRADER_TRANSACTIONS_BALANCE'] = 'false'
      end

      context 'when the trader has no transactions' do
        it 'returns 0' do
          expect(trader.balance).to eq 0
        end
      end

      context 'when the trader has transactions' do
        it 'retrieves the sum of trader transactions' do
          TraderTransaction.create!(trader: trader, amount: 50)
          TraderTransaction.create!(trader: trader, amount: -25)
          expect(trader.balance).to eq 25
        end
      end
    end

    context 'when the new feature is not enabled' do
      it 'returns the balance from the traders table' do
        expect(trader.balance).to eq 999
      end
    end
  end
end
