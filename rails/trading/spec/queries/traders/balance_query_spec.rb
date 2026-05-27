require 'rails_helper'

RSpec.describe Traders::BalanceQuery do
  let(:trader) { Trader.create!(name: 'Test Trader', email: 'query.test@example.com', balance: 123.45) }

  describe '.call' do
    context 'when the feature flag is disabled' do
      it 'returns the balance from the database column' do
        expect(described_class.call(trader)).to eq(123.45)
      end
    end

    context 'when the feature flag is enabled' do
      around(:each) do |example|
        ENV['TRADER_TRANSACTIONS_BALANCE'] = 'true'
        example.run
      ensure
        ENV['TRADER_TRANSACTIONS_BALANCE'] = 'false'
      end

      context 'when there are no transactions' do
        it 'returns 0' do
          expect(described_class.call(trader)).to eq(0)
        end
      end

      context 'when there are transactions' do
        it 'returns the sum of transaction amounts' do
          trader.trader_transactions.create!(amount: 100.0)
          trader.trader_transactions.create!(amount: -25.5)
          expect(described_class.call(trader)).to eq(74.5)
        end
      end
    end
  end
end
