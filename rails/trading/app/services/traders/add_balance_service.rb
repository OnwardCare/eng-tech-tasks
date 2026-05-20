module Traders
  class AddBalanceService < ApplicationService
    def initialize(email:, amount:)
      @email = email
      @amount = amount
    end

    def call
      trader = Trader.find_by!(email: @email)
      # Alternatively we could use a row-level lock, but since we only need to update a single column, this is more efficient.
      Trader.increment_counter(:balance, trader.id, by: @amount.to_f)
      trader.reload
      Result.new(data: trader)
    rescue ActiveRecord::RecordNotFound
      Result.new(errors: ['Trader not found'], error_type: :not_found)
    end
  end
end
