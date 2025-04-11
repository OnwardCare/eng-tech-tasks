# frozen_string_literal: true

# UpdateTraderBalanceService is a service object responsible for updating a Trader's balance.
# It inherits from BaseTraderService and implements the `call` method to perform the balance update operation.
#
# Example usage:
#   trader = Trader.find_by(email: 'trader@example.com')
#   params = { amount: '200.00' }
#   service = UpdateTraderBalanceService.new(trader, params).call
#
#   if result.success?
#     puts "Balance updated successfully: #{result.trader}"
#   else
#     puts "Failed to update balance: #{result.error}"
#   end
class UpdateTraderBalanceService < BaseTraderService
  def initialize(trader, params)
    super
    @amount = @params[:amount]
  end

  # Executes the service logic to add balance to the Trader object.
  #
  # @return [Result] A Result object encapsulating the outcome of the operation.
  #   - `success?` [Boolean]: True if the operation was successful, false otherwise.
  #   - `trader` [Trader, nil]: The Trader object with the updated balance, or nil if the operation failed.
  #   - `error` [String, nil]: An error message if the operation failed, or nil if successful.
  def call
    if @amount.present? && @amount.to_f >= 0
      @trader.add_balance(@amount)
      return Result.new(true, @trader, nil)
    end
    Result.new(false, nil, 'Invalid balance amount')
  end
end
