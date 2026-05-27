class Trader < ApplicationRecord
  has_many :trader_transactions

  # Rails 7.1 added support for atomic incrementing, but this project is on Rails 7.0
  # https://github.com/rails/rails/pull/48128
  def self.increment_counter(counter_name, id, by: 1)
    where(id: id).update_all(["#{counter_name} = COALESCE(#{counter_name}, 0) + ?", by.to_f])
  end

  def balance
    Traders::BalanceQuery.call(self)
  end
end
