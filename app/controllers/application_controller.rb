class ApplicationController < ActionController::Base
  UNSTORED_LOCATIONS = ['/users/sign_up', '/users/sign_in', '/users/password', '/users/sign_out', '/users/invitation']

  before_filter :store_location
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  serialization_scope :current_scope

  def current_account
    params[:account_id] && Account.find_by(slug: params[:account_id])
  end

  # Used by serializers for request context
  def current_scope
    OpenStruct.new(
      current_user: current_user,
      current_account: current_account
    )
  end

  def store_location
    if !UNSTORED_LOCATIONS.include?(request.fullpath) && !request.xhr?
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || inbox_account_conversations_path(resource.accounts.first)
  end

  def authorize!(policy)
    policy.access? || raise(ActiveRecord::RecordNotFound)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation) do |u|
      u.permit(:email, :name, :password, :invitation_token)
    end
  end

end
