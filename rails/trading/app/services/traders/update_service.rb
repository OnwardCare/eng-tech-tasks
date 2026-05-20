module Traders
  class UpdateService < ApplicationService
    def initialize(email:, name:)
      @email = email
      @name = name
    end

    def call
      trader = Trader.find_by!(email: @email)
      trader.name = @name
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
