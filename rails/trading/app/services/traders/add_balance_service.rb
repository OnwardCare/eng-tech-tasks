module Traders
  class AddBalanceService < ApplicationService
    def initialize(email:, amount:)
      @email = email
      @amount = amount
    end

    def call
      trader = Trader.find_by!(email: @email)
      begin
        trader.trader_transactions.create!(amount: @amount)
        Result.new(data: trader)
      rescue StandardError => ex
        Result.new(errors: [ex.message], error_type: :validation_error)
      end
    rescue ActiveRecord::RecordNotFound
      Result.new(errors: ['Trader not found'], error_type: :not_found)
    end
  end
end
