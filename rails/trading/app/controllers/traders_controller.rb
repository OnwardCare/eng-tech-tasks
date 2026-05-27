class TradersController < ApplicationController
  def register
    result = Traders::RegisterService.call(**trader_params.to_h.symbolize_keys)
    render_service_result(result, success_status: 201)
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

  def balance
    trader = Trader.find_by!(email: params[:email])
    render json: { balance: trader.balance.to_f }
  rescue ActiveRecord::RecordNotFound
    render status: 404
  end

  def update
    result = Traders::UpdateService.call(email: params[:email], name: params[:name])
    render_service_result(result)
  end

  def add
    result = Traders::AddBalanceService.call(email: params[:email], amount: params[:amount])
    render_service_result(result)
  end

  private

  def render_service_result(result, success_status: :ok)
    if result.success?
      render json: result.data, status: success_status
    else
      render_service_error(result)
    end
  end

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
