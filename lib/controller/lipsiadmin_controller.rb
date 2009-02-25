module Lipsiadmin#:nodoc:
  module Controller#:nodoc:
    # Base Backend Controller that define:
    # 
    #   layout false
    #   before_filter :backend_login_required
    #   helper Lipsiadmin::View::Helpers::BackendHelper
    # 
    class Base < ActionController::Base
      def self.inherited(subclass)#:nodoc:
        super
        subclass.layout false
        subclass.before_filter :backend_login_required
        subclass.helper Lipsiadmin::View::Helpers::BackendHelper
      end
    end
  end
end