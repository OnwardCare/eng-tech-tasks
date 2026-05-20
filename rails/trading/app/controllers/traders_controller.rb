class TradersController < ApplicationController
  def register
    result = Traders::RegisterService.call(**trader_params.to_h.symbolize_keys)
    if result.success?
      render json: result.data, status: 201
    else
      render_service_error(result)
    end
  end

  def all
    render json: Trader.order(:id)
  end

  def find
    trader = Trader.find_by!(email: params[:email])
    render json: trader
  rescue ActiveRecord::RecordNotFound
    render status: 404
  end

  def update
    result = Traders::UpdateService.call(email: params[:email], name: params[:name])
    if result.success?
      render json: result.data
    else
      render_service_error(result)
    end
  end

  def add
    result = Traders::AddBalanceService.call(email: params[:email], amount: params[:amount])
    if result.success?
      render json: result.data
    else
      render_service_error(result)
    end
  end

  private

  def render_service_error(result)
    status = if result.error_type == :not_found
               404
             else
               400
             end
    render status: status
  end

  def trader_params
    params.permit(:name, :email, :balance)
  end
end
