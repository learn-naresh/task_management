require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users
  resources :tasks
  root 'tasks#index'

  get '/redirect', to: 'calendars#redirect'

  get '/callback', to: 'calendars#callback'

  get '/calendars', to: 'calendars#calendars'

  get '/events/:calendar_id', to: 'calendars#events', as: 'events'
end
