class FrontendController <  ApplicationController
  layout "frontend"
  helper Lipsiadmin::View::Helpers::FrontendHelper
  #before_filter :frontend_login_required
end