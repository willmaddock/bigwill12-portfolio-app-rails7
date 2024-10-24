class ApplicationController < ActionController::Base
  # Run the configure_permitted_parameters method before each Devise controller action
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Override the Devise method to redirect to the student's profile page after sign-in
  def after_sign_in_path_for(resource)
    student_path(current_student) # Redirect to the logged-in student's profile
  end

  # Protected methods
  protected

  # Override configure_permitted_parameters method to allow additional parameters
  def configure_permitted_parameters
    # Parameters allowed during sign-up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :major, :graduation_date, :profile_picture])

    # Parameters that can be updated during account edit
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :major, :graduation_date, :profile_picture])
  end
end