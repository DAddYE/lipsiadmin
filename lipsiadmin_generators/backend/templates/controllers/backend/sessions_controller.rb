# This controller handles the login/logout function of the site.  
class Backend::SessionsController < ApplicationController
  layout "backend"
  
  def create
    self.current_account = Account.authenticate(params[:email], params[:password])
    if logged_in?
      redirect_back_or_default(backend_path)
    else
      flash[:notice] = I18n.t("backend.sessions.wrong")
      redirect_to new_backend_session_path
    end
  end

  def destroy
    reset_session
    flash[:notice] = I18n.t("backend.sessions.logout")
    redirect_back_or_default('/')
  end
end
