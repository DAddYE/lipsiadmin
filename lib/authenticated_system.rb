module LipsiaSoft
  module AuthenticatedSystem
    protected
    
      def logged_in?
        current_account != :false
      end

      def current_account
        @current_account ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
      end

      def current_account=(new_account)
        session[:account] = (new_account.nil? || new_account.is_a?(Symbol)) ? nil : new_account.id
        @current_account = new_account
      end
      
      # If the current actions are in our access rule will be verifyed
      def allowed?
        return AccessControl.allowed_controllers(current_account.role, current_account.modules).include?(params[:controller])
      end
      
      def authorized?
        logged_in? && current_account.active? && allowed?
      end
      
      def login_required
        authorized? || access_denied
      end

      def access_denied
        respond_to do |accepts|
          accepts.html do
            #store_location
            redirect_to :controller => "backend/sessions", :action => :new
          end
          accepts.xml do
            headers["Status"]           = "Unauthorized"
            headers["WWW-Authenticate"] = %(Basic realm="Web Password")
            render :text => "Could't authenticate you", :status => '401 Unauthorized'
          end
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

      def login_from_basic_auth
        email, passwd = get_auth_data
        self.current_account = Account.authenticate(email, passwd) if email && passwd
      end

      # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
      def login_from_cookie      
        account = cookies[:auth_token] && Account.find_by_remember_token(cookies[:auth_token])
        if account && account.remember_token?
          account.remember_me
          cookies[:auth_token] = { :value => account.remember_token, :expires => account.remember_token_expires_at }
          self.current_account = account
        end
      end

    private
      @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
      # gets BASIC auth info
      def get_auth_data
        auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
        auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
        return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
      end
  end
end
