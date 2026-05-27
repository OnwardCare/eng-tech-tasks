class Trader < ApplicationRecord
  has_many :trader_transactions

  def balance
    Traders::BalanceQuery.call(self)
  end

  def serializable_hash(options = nil)
    super.merge('balance' => balance)
  end
end
