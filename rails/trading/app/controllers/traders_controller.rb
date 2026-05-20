class TradersController < ApplicationController
  def register
    trader = Trader.new(trader_params)
    
    begin
      if trader.save
        render json: trader, status: 201
      else
        render status: 400
      end
    rescue ActiveRecord::RecordNotUnique
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
    if trader
      trader.name = params[:name]
      trader.save
      render json: trader
    else
      render status: 404
    end
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
