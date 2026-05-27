require 'rails_helper'

describe 'Traders', type: :request do
  let(:now) { Time.now.utc }

  before do
    allow(Time).to receive(:now).and_return(now)
  end

  let(:trader1) do
    {
      name: 'Amanda Rosales',
      email: 'amanda.rosales89@hotmail.com',
      balance: 23.6
    }
  end

  it 'performs correctly in a successful flow' do
    post '/trading/traders/register', params: trader1
    expect(response.status).to eq(201)

    expected_trader_response = {
      id: 1,
      name: 'Amanda Rosales',
      email: 'amanda.rosales89@hotmail.com',
      balance: 23.6,
      created_at: now.as_json,
      updated_at: now.as_json
    }.stringify_keys
    expect(JSON.parse(response.body)).to eq(expected_trader_response)

    get '/trading/traders/all'

    expected = [expected_trader_response]

    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq(expected)

    get '/trading/traders', params: { email: trader1[:email] }
    expect(response.status).to eq(200)

    expect(JSON.parse(response.body)).to eq(expected_trader_response)

    put '/trading/traders', params: { email: trader1[:email], name: 'Updated name' }
    expect(response.status).to eq(200)

    get '/trading/traders', params: { email: trader1[:email] }
    expect(JSON.parse(response.body)['name']).to eq('Updated name')

    put '/trading/traders/add', params: { email: trader1[:email], amount: 100 }
    expect(response.status).to eq(200)

    get '/trading/traders', params: { email: trader1[:email] }
    expect(JSON.parse(response.body)['balance']).to eq(trader1[:balance] + 100)
  end

  describe 'POST /trading/traders/register' do
    context 'when user with same email exists' do
      before do
        post '/trading/traders/register', params: trader1
      end

      it 'returns status code 400' do
        post '/trading/traders/register', params: trader1
        expect(response.status).to eq(400)
      end
    end
  end

  describe 'PUT /trading/traders' do
    before do
      post '/trading/traders/register', params: trader1
    end

    context 'when trader by given email does not exist' do
      it 'returns 404' do
        put '/trading/traders', params: { email: 'non.existing@email.com', name: 'Updated name' }
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'PUT /trading/traders/add' do
    before do
      post '/trading/traders/register', params: trader1
    end

    context 'when trader by given email exists' do
      let!(:trader) do
        Trader.create!(name: 'Original Name', email: 'test@example.com').tap do |t|
          t.trader_transactions.create!(amount: 50.0)
        end
      end
      it 'returns 200' do
        put '/trading/traders/add', params: { email: trader.email, amount: 100 }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['balance']).to eq(150.0)
      end
    end

    context 'when trader by given email does not exist' do
      it 'returns 404' do
        put '/trading/traders/add', params: { email: 'non.existing@email.com', amount: 100 }
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'GET /trading/traders?email=' do
    before do
      post '/trading/traders/register', params: trader1
    end

    it 'returns 404 if trader is not found' do
      get '/trading/traders', params: { email: 'non.existing@email.com' }
      expect(response.status).to eq(404)
    end
  end

  describe 'GET /trading/traders/balance' do
    let!(:trader) { Trader.create!(name: 'Balance Trader', email: 'balance.test@example.com') }

    it 'returns 200 and the balance derived from transactions' do
      trader.trader_transactions.create!(amount: 100.0)
      trader.trader_transactions.create!(amount: -25.5)

      get '/trading/traders/balance', params: { email: trader.email }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq({ 'balance' => 74.5 })
    end

    it 'returns 404 if trader does not exist' do
      get '/trading/traders/balance', params: { email: 'non.existent@example.com' }
      expect(response.status).to eq(404)
    end
  end
end
