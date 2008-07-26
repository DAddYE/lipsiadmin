class BackendController <  ApplicationController
  before_filter :login_required, :except => [:activate]
  layout false
  helper LipsiaSoft::LipsiadminHelper
end