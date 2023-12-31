# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create], if: :devise_controller?
  # before_action :configure_account_update_params, only: [:update], if: :devise_controller?

  # GET /resource/sign_up
  def new
    build_resource({})
    resource.build_user_information
    respond_with self.resource
  end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def after_update_path_for(resource)
    user_path(resource)
  end

  def update_resource(resource, params)
    if current_user.uid && current_user.provider
      resource.update_without_password(params)
    else
      super
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up) do |u|
  #     u.permit(:email, :password, :password_confirmation,
  #         user_information_attributes: [:first_name, :last_name, :date_of_birth])
  #   end
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update) do |u|
  #     u.permit(:avatar, user_information_attributes: [:hometown, :about_me])
  #   end
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
