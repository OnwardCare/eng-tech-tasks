Rails.application.routes.draw do
  resources :traders, only: [], path: '/trading/traders' do
    post 'register', on: :collection
    get 'all', on: :collection
    get 'balance', on: :collection
    get '', on: :collection, action: :find
    put '', on: :collection, action: :update
    put 'add', on: :collection
  end
end
