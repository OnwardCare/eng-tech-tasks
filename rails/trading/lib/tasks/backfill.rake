namespace :trader_transactions do
  desc 'Backfills trader transactions'
  task backfill: :environment do
    File.open('log/trader-backfill-errors.log', 'w') do |file|
      logger = Logger.new(file)
      Trader.find_each do |trader|
        TraderTransaction.create!(trader: trader, amount: trader.balance)
      rescue StandardError => ex
        logger.error ex.message
      end
    end
  end
end
