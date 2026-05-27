module Traders
  class BalanceQuery
    def initialize(trader)
      @trader = trader
    end

    def call
      if ENV['TRADER_TRANSACTIONS_BALANCE'] == 'true'
        # TODO: the amount is casted to float because bigdecimals are
        # transformed to strings when jsonified and the request specs
        # expect numbers instead of strings. The view layer should
        # handle transforming bigdecimals into numbers instead, but we
        # don't currently have anything to hook into.
        @trader.trader_transactions.sum(:amount).to_f
      else
        @trader.read_attribute(:balance).to_f
      end
    end

    def self.call(trader)
      new(trader).call
    end
  end
end
