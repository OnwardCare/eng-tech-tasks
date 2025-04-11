# frozen_string_literal: true

# TradersController is responsible for handling requests related to traders.
# It provides actions index, show, create, update, and add balance to traders.
# Inherits from ApplicationController and uses ApiResponses for rendering responses.
class TradersController < ApplicationController

  def index
    render_success(data: Trader.ordered)
  end

  def show
    render_success(data: trader)
  end

  def create
    trader = Trader.new(trader_params)
    if trader.save
      render_success(data: trader, status: 201)
    else
      render_bad_request(error: trader.errors.full_messages.join(', '))
    end
  end

  def update
    result = TraderUpdaterService.new(trader, **trader_params.to_h.symbolize_keys).call
    if result.success?
      render_success(data: result.trader)
    else
      render_bad_request(error: result.error)
    end
  end

  def add
    result = UpdateTraderBalanceService.new(trader, **add_balance_params.to_h.symbolize_keys).call
    if result.success?
      render_success(data: result.trader)
    else
      render_bad_request(error: result.error)
    end
  end

  private

  def trader_params
    params.permit(:name, :email, :balance)
  end

  def add_balance_params
    params.permit(:email, :amount)
  end

  def trader
    @trader ||= Trader.find_by!(email: trader_params[:email])
  end
end
