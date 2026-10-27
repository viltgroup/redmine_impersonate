class ImpersonationController < ApplicationController
  before_action :require_login
  before_action :require_admin, only: [:create]

  require_sudo_mode :create

  # Session keys that belong to the administrator's login itself rather than to
  # any page state, so they must survive the reset below.
  #
  # redmine_oauth's token check logs out any session whose provider session it
  # cannot find, and an SSO-forced account always needs one. It already looks
  # the provider session up by :true_user_id while impersonating; it just needs
  # these keys still in the session to find it. Dropping them is what logged
  # the administrator out on the first request after Impersonate.
  CARRIED_SESSION_KEYS = [:oauth_session_id, :oauth_login]

  def create
    if !session[:true_user_id]
      admin_user = User.current
      impersonated_user = User.active.logged.find(params[:user_id])
      carried = CARRIED_SESSION_KEYS.index_with { |key| session[key] }.compact

      # Clear any remaining data in admin's old session
      reset_session
      carried.each { |key, value| session[key] = value }

      # Remember the original admin user in the session and set the new user for the rest of request
      session[:true_user_id] = admin_user.id
      User.current = impersonated_user

      # Start a new session for the impersonated user
      start_user_session(impersonated_user)

      # Don't require password change of target user
      session.delete(:pwd)
    end

    # Redirect to the home with the new impersonated user
    redirect_to home_url
  end

  def destroy
    true_user = User.find_by_id(session[:true_user_id])

    if true_user && true_user.active?
      # redmine_oauth's override of logged_user= carries the administrator's
      # provider session across this reset, as it belongs to true_user.
      self.logged_user = true_user
      session.delete(:true_user_id)
    end

    # redirect_to :back was removed in Rails 5.1, so Cancel raised instead.
    redirect_back(fallback_location: home_url)
  end
end
