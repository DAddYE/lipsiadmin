class FrontendController <  ApplicationController
  layout "frontend"
  before_filter :login_frontend_required, :except => [:login]
end