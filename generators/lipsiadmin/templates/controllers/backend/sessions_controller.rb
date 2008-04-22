# This controller handles the login/logout function of the site.  
class Backend::SessionsController < ApplicationController
  layout false
  
  def create
    self.current_account = Account.authenticate(params[:email], params[:password])
    if logged_in?
      redirect_back_or_default(backend_path)
    else
      flash[:notice] = "Wrong user or password"
      redirect_to new_backend_session_path
    end
  end

  def destroy
    self.current_account.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "Correctly Logged Out"
    redirect_back_or_default('/')
  end
end
