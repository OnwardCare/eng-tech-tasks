# frozen_string_literal: true

# BaseTraderService is a base class for trader-related service objects.
# It provides a common structure and behavior for services that operate on Trader objects.
#
# Example usage:
#   trader = Trader.find_by(email: 'trader@example.com')
#   params = { amount: '100.50' }
#   service = UpdateTraderBalanceService.new(trader, params).call
#
#   if result.success?
#     puts "Operation successful: #{result.trader}"
#   else
#     puts "Operation failed: #{result.error}"
#   end
class BaseTraderService
  # Result is a Struct used to encapsulate the outcome of a service operation.
  # It provides a standardized way to represent the success or failure of an operation.
  #
  # @attribute success? [Boolean] Indicates whether the operation was successful.
  # @attribute trader [Trader, nil] The Trader object involved in the operation, or nil if unsuccessful.
  # @attribute error [String, nil] An error message if the operation failed, or nil if successful.
  Result = Struct.new(:success?, :trader, :error)

  # Initializes a new instance of BaseTraderService.
  #
  # @param trader [Trader] The Trader object the service will operate on.
  # @param params [Hash] A hash of parameters required for the service operation.
  def initialize(trader, params)
    @trader = trader
    @params = params
  end

  # Executes the service logic.
  # This method must be implemented by subclasses to define specific behavior.
  #
  # @raise [NotImplementedError] If the method is not implemented in a subclass.
  def call
    raise NotImplementedError, 'Subclasses must implement a call method'
  end
end
