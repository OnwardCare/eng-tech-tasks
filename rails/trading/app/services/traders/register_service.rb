module Traders
  class RegisterService < ApplicationService
    def initialize(name: nil, email: nil, balance: nil)
      @name = name
      @email = email
      @balance = balance
    end

    def call
      trader = Trader.new(name: @name, email: @email, balance: @balance)
      if trader.save
        Result.new(data: trader)
      else
        Result.new(errors: trader.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotUnique
      # While technically not a validation error, this is caused by a duplicate email, so return a validation error message.
      Result.new(errors: ['Email has already been taken'], error_type: :validation_error)
    end
  end
end
