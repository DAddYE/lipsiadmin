class BackendController <  ApplicationController
  before_filter :backend_login_required, :except => [:activate]
  layout "backend"
  helper LipsiaSoft::LipsiAdminHelper
end