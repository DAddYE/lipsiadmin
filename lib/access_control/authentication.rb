module Lipsiadmin
  module AccessControl
    # This provide a simple login for backend and frontend.
    # Use backend_login_required in backend and
    # frontend_login_requirded in frontend.
    # 
    #   Examples:
    # 
    #     class FrontendController <  ApplicationController
    #       before_filter :frontend_login_required, :except => [:login]
    #     end
    # 
    module Authentication
      protected
        
        # Returns true if <tt>current_account</tt> is logged and active.
        def logged_in?
          current_account != :false && current_account.active?
        end
        
        # Returns the current_account, it's an instance of <tt>Account</tt> model
        def current_account
          @current_account ||= (login_from_session || :false)
        end
        
        # Ovverride the current_account, you must provide an instance of Account Model
        # 
        #   Examples:
        #   
        #     current_account = Account.last
        # 
        def current_account=(new_account)
          session[:account] = (new_account.nil? || new_account.is_a?(Symbol)) ? nil : new_account.id
          @current_account = new_account
        end

        # Returns true if the <tt>current_account</tt> is allowed to see the requested
        # controller/action.
        # 
        # For configure this role please refer to: <tt>Lipsiadmin::AccessControl::Base</tt>
        def allowed?
          maps = AccountAccess.maps_for(current_account)
          
          allowed = maps.collect(&:allowed).flatten.uniq
          denied  = maps.collect(&:denied).flatten.uniq
          
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

        # Returns a helper to pass in a <tt>before_filter</tt> for check if
        # an account are: <tt>logged_in?</tt> and <tt>allowed?</tt>
        # 
        # By default this method is used in BackendController so is not necessary
        def backend_login_required
          logged_in?  && allowed? || access_denied(:backend)
        end
        
        # Returns a helper to pass in a <tt>before_filter</tt> for check if
        # an account are: <tt>logged_in?</tt> and <tt>allowed?</tt>
        #
        #   Examples:
        # 
        #     before_filter :frontend_login_required, :except => [:some]
        # 
        def frontend_login_required
          logged_in?  && allowed? || access_denied(:frontend)
        end

        def access_denied(where)#:nodoc:
          respond_to do |format|
            format.html { redirect_to :controller => "#{where}/sessions", :action => :new }
            format.js { render(:update) { |page| page.alert "You don't allowed to access to this javascript" } }
          end
          false
        end

        def store_location#:nodoc:
          session[:return_to] = request.request_uri
        end
        
        # Redirect the account to the page that requested an authentication or
        # if the account is not allowed/logged return it to a default page
        def redirect_back_or_default(default)
          redirect_to(session[:return_to] || default)
          session[:return_to] = nil
        end

        def self.included(base)#:nodoc:
          base.send :helper_method, :current_account, :logged_in?
        end

        def login_from_session#:nodoc:
          self.current_account = Account.find_by_id(session[:account]) if session[:account]
        end
    end # Module Authentication
  end # Module AccessControl
end # Module Backend
