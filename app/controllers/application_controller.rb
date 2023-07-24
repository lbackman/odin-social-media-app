class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_notifications, if: :current_user
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_out_path_for(resource_or_scope)
    unauthenticated_root_path
  end

  def render_access_denied
    render :file => "#{Rails.root}/public/403.html",  :status => 403, layout: false, status: :forbidden
  end

  private

  def set_notifications
    notifications = Notification.where(recipient: current_user).newest_first.limit(9).includes([:recipient])
    @unread = notifications.unread
    @read = notifications.read
  end

  def mark_notifications_as_read(notifications)
    if current_user
      notifications.where(read_at: nil).update_all(read_at: Time.zone.now)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(
      :email, :password, :password_confirmation,
      user_information_attributes: [:id, :first_name, :last_name, :date_of_birth]
    )}

    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(
      :avatar, :current_password, user_information_attributes: [:id, :hometown, :about_me]
    )}
  end
end
