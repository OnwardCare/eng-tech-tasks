module Traders
  class AddBalanceService < ApplicationService
    def initialize(email:, amount:)
      @email = email
      @amount = amount
    end

    def call
      trader = Trader.find_by!(email: @email)
      trader.balance += @amount.to_f
      if trader.save
        Result.new(data: trader)
      else
        Result.new(errors: trader.errors.full_messages, error_type: :validation_error)
      end
    rescue ActiveRecord::RecordNotFound
      Result.new(errors: ['Trader not found'], error_type: :not_found)
    end
  end
end
