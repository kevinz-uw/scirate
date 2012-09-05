class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :user_signed_in
  helper_method :current_user
  helper_method :check_authorized
  helper_method :check_param

  private
  def user_signed_in
    return ((session.include? :user_id) and (current_user != nil))
  end

  private
  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  private
  def check_authorized
    raise Exception, 'not authorized' unless current_user
  end

  private
  def check_param(sym)
    if not params[sym]
      raise Exception, "missing required parameter: #{sym.to_s}"
    end
  end
end
