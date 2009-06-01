module Lipsiadmin
  module AccessControl
    module Helper#:nodoc:
      def recognize_path(path)#:nodoc:
        case path
          when String then ActionController::Routing::Routes.recognize_path(path, :method => :get)
          when Hash   then path
        end
      end
    end
    
    # This Class map and get roles/projects for accounts
    # 
    #   Examples:
    #   
    #     roles_for :administrator do |role, current_account|
    #       role.allow_all_actions "/backend/base"
    #       role.deny_action_of    "/backend/accounts/details"
    #     
    #       role.project_module :administration do |project|
    #         project.menu :general_settings, "/backend/settings" do |submenu|
    #           submenu.add :accounts, "/backend/accounts" do |submenu|
    #             submenu.add :sub_accounts, "/backend/accounts/subaccounts"
    #           end
    #         end
    #       end
    # 
    #       role.project_module :categories do |project|
    #         current_account.categories.each do |cat|
    #           project.menu cat.name, "/backend/categories/#{cat.id}.js"
    #         end
    #       end
    #     end
    # 
    #   If a user logged with role administrator or that have a project_module administrator can:
    #   
    #   - Access in all actions of "/backend/base" controller
    #   - Denied access to ONLY action <tt>"/backend/accounts/details"</tt>
    #   - Access to a project module called Administration
    #   - Access to all actions of the controller "/backend/settings"
    #   - Access to all actions of the controller "/backend/categories"
    #   - Access to all actions EXCEPT <tt>details</tt> of controller "/backend/accounts"
    # 
    class Base
      
      class << self
        
        # We map project modules for a given role or roles
        def roles_for(*roles, &block)
          roles.each { |role| raise AccessControlError, "Role #{role} must be a symbol!" unless role.is_a?(Symbol)  }
          @mappers ||= []
          @roles   ||= []
          @roles.concat(roles)
          @mappers << Proc.new { |account| Mapper.new(account, *roles, &block) }
        end
        
        # Returns all roles
        def roles
          @roles.nil? ? [] : @roles.collect(&:to_s)
        end
        
        def maps_for(account)
          @mappers.collect { |m| m.call(account) }.
                   reject  { |m| !m.allowed? }
        end
      end
      
    end
    
    class Mapper
      include Helper
      attr_reader :project_modules, :roles
      
      def initialize(account, *roles, &block)#:nodoc:
        @project_modules = []
        @allowed         = []
        @denied          = []
        @roles           = roles
        @account         = account
        # Mantain backward compatibility
        yield(self, @account) rescue yield(self)
      end
      
      # Create a new project module
      def project_module(name, controller=nil, &block)
        @project_modules << ProjectModule.new(name, controller, &block)
      end
      
      # Globally allow an action of a controller for the current role
      def allow_action(path)
        @allowed << recognize_path(path)
      end
      
      # Globally deny an action of a controllerfor the current role
      def deny_action(path)
        @denied << recognize_path(path)
      end
      
      # Globally allow all actions from a controller for the current role
      def allow_all_actions(path)
        @allowed << { :controller => recognize_path(path)[:controller] }
      end
      
      # Globally denty all actions from a controller for the current role
      def deny_all_actions(path)
        @denied << { :controller => recognize_path(path)[:controller] }
      end
      
      # Return true if current_account role is included in given roles
      def allowed?
        @roles.any? { |r| r.to_s.downcase == @account.role.downcase }
      end
      
      # Return allowed actions/controllers
      def allowed
        # I know is a double check but is better 2 times that no one.
        if allowed?
          @project_modules.each { |pm| @allowed.concat pm.allowed  }
          @allowed.uniq
        else 
          []
        end
      end
      
      # Return denied actions/controllers
      def denied
        @denied.uniq
      end
    end
    
    class ProjectModule
      include Helper
      include ActionController::UrlWriter
      attr_reader :name, :menus, :url
      
      def initialize(name, path=nil, options={}, &block)#:nodoc:
        @name = name
        @options = options
        @allowed = []
        @menus   = []
        if path
          @url      = recognize_path(path)
          @allowed << { :controller => @url[:controller] }
        end
        yield self
      end
      
      # Build a new menu and automaitcally add the action on the allowed actions.
      def menu(name, path=nil, options={}, &block)
        @menus << Menu.new(name, path, options, &block)
      end
      
      # Return allowed controllers
      def allowed
        @menus.each { |m| @allowed.concat(m.allowed) }
        @allowed.uniq
      end
      
      # Return the original name or try to translate or humanize the symbol
      def human_name
        @name.is_a?(Symbol) ? I18n.t("backend.menus.#{@name}", :default => @name.to_s.humanize) : @name
      end
      
      # Return a unique id for the given project module
      def uid
        @name.to_s.downcase.gsub(/[^a-z0-9]+/, '').gsub(/-+$/, '').gsub(/^-+$/, '')
      end
      
      # Return ExtJs Config for this project module
      def config
        options = @options.merge(:text => human_name)
        options.merge!(:menu => @menus.collect(&:config)) if @menus.size > 0
        options.merge!(:handler =>  "function(){ Backend.app.load('#{url_for(@url.merge(:only_path => true))}') }".to_l) if @url
        options
      end
    end
    
    class Menu
      include Helper
      include ActionController::UrlWriter
      attr_reader :name, :options, :url, :items
      
      def initialize(name, path=nil, options={}, &block)#:nodoc:
        @name    = name
        @options = options
        @allowed = []
        @items   = []        
        if path
          @url     = recognize_path(path) 
          @allowed << { :controller => @url[:controller] } if path
        end
        yield self if block_given?
      end
      
      # Add a new submenu to the menu
      def add(name, path=nil, options={}, &block)
        @items << Menu.new(name, path, options, &block)
      end
      
      # Return allowed controllers
      def allowed
        @items.each { |i| @allowed.concat i.allowed }
        @allowed.uniq
      end
      
      # Return the original name or try to translate or humanize the symbol
      def human_name
        @name.is_a?(Symbol) ? I18n.t("backend.menus.#{@name}", :default => @name.to_s.humanize) : @name
      end
      
      # Return a unique id for the given project module
      def uid
        @name.to_s.downcase.gsub(/[^a-z0-9]+/, '').gsub(/-+$/, '').gsub(/^-+$/, '')
      end
      
      # Return ExtJs Config for this menu
      def config
        if @url.blank?
          options = human_name
        else
          options = @options.merge(:text => human_name)
          options.merge!(:menu => @items.collect(&:config)) if @items.size > 0
          options.merge!(:handler => "function(){ Backend.app.load('#{url_for(@url.merge(:only_path => true))}') }".to_l)
        end
        options
      end
    end
    
    class AccessControlError < StandardError#:nodoc:
    end
  end
end