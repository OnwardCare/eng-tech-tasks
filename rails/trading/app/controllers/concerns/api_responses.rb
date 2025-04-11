# frozen_string_literal: true

# ApiResponses is a module that provides common methods for handling API responses
# and error rendering in application. It includes methods for rendering
# success responses, error responses, and handling specific exceptions.
module ApiResponses
  extend ActiveSupport::Concern

  included do
    # Automatically rescues from ActiveRecord::RecordNotFound exceptions
    # and renders a 404 error response.
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  end

  # Renders a 404 Not Found error response.
  def render_not_found
    render_error error: 'Record not found', status: 404
  end

  # Renders a 400 Bad Request error response with a custom error message.
  #
  # @param error [String] The error message to include in the response. Defaults to 'Bad request'.
  def render_bad_request(error: 'Bad request')
    render_error error: error, status: 400
  end

  # Renders a generic error response with a custom error message and status code.
  #
  # @param error [String] The error message to include in the response. Defaults to 'Something went wrong'.
  # @param status [Integer] The HTTP status code for the response. Defaults to 500.
  def render_error(error: 'Something went wrong', status: 500)
    render json: { error: error }, status: status
  end

  # Renders a success response with optional data and a status code.
  #
  # @param data [Hash, Array, {}] The data to include in the response. Defaults to {}.
  # @param status [Integer] The HTTP status code for the response. Defaults to 200.
  def render_success(data: {}, status: 200)
    render json: data, status: status
  end
end
