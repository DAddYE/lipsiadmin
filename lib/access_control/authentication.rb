module Lipsiadmin
  module AccessControl
    # This provide a simple login for backend and frontend.
    # Use backend_login_required in backend and
    # frontend_login_requirded in frontend.
    module Authentication
      protected
        def logged_in?
          current_account != :false && current_account.active?
        end

        def current_account
          @current_account ||= (login_from_session || :false)
        end

        def current_account=(new_account)
          session[:account] = (new_account.nil? || new_account.is_a?(Symbol)) ? nil : new_account.id
          @current_account = new_account
        end

        def allowed?

          allowed = current_account.maps.collect(&:allowed)[0]
          denied  = current_account.maps.collect(&:denied)[0]
          
          allow = allowed.find do |a|
            a[:controller] == params[:controller] &&
            (a[:action].blank? || a[:action] == params[:action])
          end
          
          deny = denied.find do |a|
            a[:controller] == params[:controller] &&
            (a[:action].blank? || a[:action] == params[:action])
          end
          
          return allow && !deny
        end

        def backend_login_required
          logged_in?  && allowed? || access_denied(:backend)
        end
      
        def fronted_login_required
          logged_in?  && allowed? || access_denied(:backend)
        end

        def access_denied(where)
          respond_to do |format|
            format.html { redirect_to :controller => "#{where}/sessions", :action => :new }
            format.js { render(:update) { |page| page.alert "You don't allowed to access to this javascript" } }
          end
          false
        end  

        def store_location
          session[:return_to] = request.request_uri
        end

        def redirect_back_or_default(default)
          redirect_to(session[:return_to] || default)
          session[:return_to] = nil
        end

        def self.included(base)
          base.send :helper_method, :current_account, :logged_in?
        end

        def login_from_session
          self.current_account = Account.find_by_id(session[:account]) if session[:account]
        end
    end # Module Authentication
  end # Module AccessControl
end # Module Backend
