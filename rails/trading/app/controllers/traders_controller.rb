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
    return render status: 404 unless trader

    render json: trader, status: 200
  end

  def update
    trader = Trader.find_by(email: params[:email])
    return render status: 404 unless trader

    trader.name = params[:name]
    trader.save
    render json: trader, status: 200
  end

  def add
    trader = Trader.find_by(email: params[:email])
    return render status: 404 unless trader

    trader.balance = trader.balance.to_f + params[:amount].to_f
    trader.save
    render json: trader, status: 200
  end

  private

  def trader_params
    params.permit(:name, :email, :balance)
  end
end
