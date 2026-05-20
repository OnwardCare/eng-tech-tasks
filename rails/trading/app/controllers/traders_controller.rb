class TradersController < ApplicationController
  def register
    trader = Trader.new(trader_params)
    
    if trader.save
      render json: trader, status: 201
    else
      render status: 400
    end
  end

  def all
    render json: Trader.order(:id)
  end

  def find
    trader = Trader.find_by(email: params[:email])
    render json: trader
  end

  def update
    trader = Trader.find_by(email: params[:email])
    trader.name = params[:name]
    trader.save
    render json: trader
  end

  def add
    trader = Trader.find_by(email: params[:email])
    trader.balance += params[:amount].to_f
    trader.save
    render json: trader
  end

  private

  def trader_params
    params.permit(:name, :email, :balance)
  end
end
