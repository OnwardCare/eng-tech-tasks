require 'rails_helper'
RSpec.describe Trader, type: :model do
  let(:trader) { Trader.create!(name: 'Test Trader', email: 'test@example.com') }
  describe '#balance' do
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
end
