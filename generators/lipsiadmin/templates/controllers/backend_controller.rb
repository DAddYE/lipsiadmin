class BackendController <  ApplicationController
  before_filter :login_required, :except => [:activate]
  layout "backend"
  helper LipsiaSoft::LipsiadminHelper
end