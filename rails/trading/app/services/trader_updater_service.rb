# frozen_string_literal: true

# TraderUpdaterService is a service object responsible for updating a Trader's name.
# It inherits from BaseTraderService and implements the `call` method to perform the update operation.
#
# Example usage:
#   trader = Trader.find_by(email: 'trader@example.com')
#   params = { name: 'New Trader Name' }
#   service = TraderUpdaterService.new(trader, params).call
#
#   if result.success?
#     puts "Trader updated successfully: #{result.trader}"
#   else
#     puts "Failed to update trader: #{result.error}"
#   end
class TraderUpdaterService < BaseTraderService
  # Executes the service logic to update the Trader's name.
  #
  # @return [Result] A Result object encapsulating the outcome of the operation.
  #   - `success?` [Boolean]: True if the operation was successful, false otherwise.
  #   - `trader` [Trader, nil]: The Trader object with the updated name, or nil if the operation failed.
  #   - `error` [String, nil]: An error message if the operation failed, or nil if successful.
  def call
    if @params[:name].present?
      @trader.update(name: @params[:name])
      return Result.new(true, @trader, nil)
    end
    Result.new(false, nil, 'Name is required')
  end
end
