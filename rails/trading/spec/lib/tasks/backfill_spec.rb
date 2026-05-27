require 'rails_helper'
require 'rake'

describe 'rake trader_transactions:backfill', type: :task do
  before :all do
    Rails.application.load_tasks
  end

  subject(:task) { Rake::Task['trader_transactions:backfill'] }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'execution' do
    let!(:traders) do
      Array.new(3) { |i| Trader.create!(name: "Trader #{i}", email: "trader#{i}@example.com", balance: 100.0 * i) }
    end

    before do
      task.reenable
    end

    it 'processes traders in batches using find_each' do
      expect(Trader).to receive(:find_each).and_call_original
      task.invoke
    end

    it 'creates a transaction for each trader with their current balance' do
      expect { task.invoke }.to change(TraderTransaction, :count).by(3)

      traders.each do |trader|
        transaction = TraderTransaction.find_by(trader_id: trader.id)
        expect(transaction).not_to be_nil
        expect(transaction.amount).to eq(trader.balance)
      end
    end
  end
end
