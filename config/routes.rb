Rails.application.routes.draw do
  root 'static_pages#top'
  
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get 'index_of_working', to: 'users#index_of_working'
  post 'import', to: 'users#import'
  
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/edit_overtime_approval'
      patch 'attendances/update_overtime_approval'
      get 'attendances/edit_attendance_approval'
      patch 'attendances/update_attendance_approval'
      get 'attendances/attendance_log'
      get 'attendances/edit_onemonth_approval'
      patch 'attendances/update_onemonth_approval'
    end
    resources :attendances, only: :update do
      member do
        get 'attendances/edit_overtime'
        patch 'attendances/update_overtime'
        patch 'attendances/update_onemonth_request'
      end
    end
  end

  resources :bases

end
