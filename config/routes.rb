# frozen_string_literal: true

Rails.application.routes.draw do
  # TODO: bugfix: polymorphic_path内で、引数がずれ（id, format => locale, id, format)）てURLが取れなくなった。
  # scope "(:locale)", locale: /ja|en|zh|nl/ do
  mount GrapeApi::API => '/'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  devise_scope :users do
    get 'users/sign_in', to: 'users/sessions#new'
    get 'users/sign_out', to: 'users/sessions#destroy'
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
    mount SwaggerUiEngine::Engine => '/swagger'
  end

  mount RailsDb::Engine => '/railsdb', :as => 'rails_db'

  authenticated :user, ->(user){ user.role? 'SYSTEM_ADMIN' } do
    mount DelayedJobWeb => '/delayed_job'
  end

  root 'home#index'
  get '/home/lectures_for_reserves', to: 'home#lectures_for_reserves'
  get '/header/search', to: 'header#search', as: 'header_search'

  resources :areas
  resources :buildings
  resources :equipments
  resources :students
  resources :courses
  resources :books
  resources :vips
  resources :klass_templates
  resources :klasses do
    get :curriculum, on: :member
    get :curriculum_schedule, on: :member
    get :duplicate, on: :member
    post :bulk_klass_subjects, on: :member
    post :fix, on: :member
  end
  resources :klass_subjects do
    post :fix, on: :member
    post :unfix, on: :member
    post :delete_lectures, on: :collection
  end
  resources :provinces
  resources :subjects
  resources :subject_categories
  resources :subject_types
  resources :lectures do
    get :duplicate, on: :member
    get :icalendar, on: :collection
    get :reserve_by_lecture, on: :member
    get :confirm_lecture, on: :collection
    get :confirm_klass_subject, on: :collection
    post :duplicate_all, on: :collection
    post :duplicate_klass_subject, on: :collection
    post :approve, on: :member
    post :unapprove, on: :member
    post :back_confirmed, on: :member
    get :klass_calendar, on: :collection
    get :staff_calendar, on: :collection
    post :cancel, on: :member
    post :change_request_for_vip, on: :member
  end
  resources :lecture_attend_logs, only: %i[index show] do
    get :build_clear_url, on: :collection
    get :clear_cookies, on: :collection
    get :cleared, on: :collection
  end
  resources :lecture_staffs, only: %i[index show]
  resources :lecture_students, only: %i[index show]
  resources :reserves do
    get :rooms_for_calendar, on: :collection
    get :calendar, on: :collection
    get :index_calendar, on: :collection
  end
  resources :roles, only: %i[index show edit update]
  resources :rooms
  resources :room_groups
  resources :staffs
  resources :students do
    get :choose_merging, on: :member
    post :change_normalized, on: :member
    get :compare_merging, on: :member
    post :merge, on: :member
    post :import, on: :collection
  end
  resources :student_mentors
  resources :student_points, only: %i[index show]
  resources :users, only: %i[index show] do
    post :lock, on: :member
    post :unlock, on: :member
  end
  resources :student_mycoaches, only: %i[index show] do
    post :lock, on: :member
    post :unlock, on: :member
  end
  get '/attends', to: 'attends#show'
  get '/attends/check', to: 'attends#check'
  get '/attends/checked', to: 'attends#checked'

  resources :student_balances, only: %i[index show]
  resources :student_billings
  resources :student_payments
  resources :student_commissions
end
