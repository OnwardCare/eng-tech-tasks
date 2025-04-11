Rails.application.routes.draw do
  resources :traders, path: '/trading/traders' do
    collection do
      get 'all', action: :index
      get '', action: :show
      post 'register', action: :create
      put '', action: :update
      put :add
    end
  end
end
