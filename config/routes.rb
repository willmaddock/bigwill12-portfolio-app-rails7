Rails.application.routes.draw do
  # Custom Devise routes for students with controllers mapped to students/registrations, students/sessions, and students/passwords
  devise_for :students, controllers: {
    registrations: 'students/registrations',
    sessions: 'students/sessions',
    passwords: 'students/passwords'
  }

  # Define resourceful routes for students
  resources :students

  # Root path of the application, directing to the index action of the StudentsController
  root "students#index"

  # Health check route to verify if the app is live
  get "up" => "rails/health#show", as: :rails_health_check
end