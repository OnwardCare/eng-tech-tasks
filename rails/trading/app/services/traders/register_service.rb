module Traders
  class RegisterService < ApplicationService
    def initialize(name: nil, email: nil, balance: nil)
      @name = name
      @email = email
      @balance = balance
    end

    def call
      trader = Trader.new(name: @name, email: @email)
      Trader.transaction do
        trader.save!
        trader.trader_transactions.create!(amount: @balance)
      end
      Result.new(data: trader)
    rescue ActiveRecord::RecordInvalid => ex
      Result.new(errors: ex.record.errors.full_messages, error_type: :validation_error)
    rescue ActiveRecord::RecordNotUnique
      # While technically not a validation error, this is caused by a duplicate email, so return a validation error message.
      Result.new(errors: ['Email has already been taken'], error_type: :validation_error)
    end
  end
end
