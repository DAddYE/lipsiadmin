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
    #     roles_for :administrator do |role|
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
    #     end
    # 
    #   If a user logged with role administrator or that have a project_module administrator can:
    #   
    #   - Access in all actions of "/backend/base" controller
    #   - Denied access to ONLY action <tt>"/backend/accounts/details"</tt>
    #   - Access to a project module called Administration
    #   - Access to all actions of the controller "/backend/settings"
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
          @mappers << Mapper.new(*roles, &block)
        end        
        
        # Returns all roles
        def roles
          @roles.collect(&:to_s)
        end
        
        # Returns all project modules ids
        def project_modules
          @mappers.inject([]) do |pm, maps|
            pm.concat(maps.project_modules.collect(&:uid))
          end.uniq
        end
        
        # Returns maps for a given role
        def find_by_role(role)
          role = case role
            when String then role.downcase.to_sym
            when Symbol then role
          end
          return @mappers.find_all { |m| m.roles.include?(role.to_sym) }
        end
      
        # Returns maps for a given project modules uids
        def find_by_project_modules(*uids)
          uids.inject([]) do |maps, uid|
            maps.concat @mappers.find_all { |m| m.project_modules.collect(&:uid).include?(uid.to_s) }
          end
        end
      end
      
    end
    
    class Mapper
      include Helper
      attr_reader :project_modules, :roles
      
      def initialize(*roles, &block)#:nodoc:
        @project_modules = []
        @allowed         = []
        @denied          = []
        @roles           = roles
        yield self
      end
      
      # Create a new project module
      def project_module(name, controller=nil, &block)
        @project_modules << ProjectModule.new(name, controller, &block)
      end
      
      # Globally but for current role allow an action
      def allow_action(path)
        @allowed << recognize_path(path)
      end
      
      # Globally but for current role deny an action
      def deny_action(path)
        @denied << recognize_path(path)
      end
      
      # Globally but for current role allow an action
      def allow_all_actions(path)
        @allowed << { :controller => recognize_path(path)[:controller] }
      end
      
      # Globally but for current role deny an action
      def deny_all_actions(path)
        @denied << { :controller => recognize_path(path)[:controller] }
      end
      
      # Return allowed actions/controllers
      def allowed
        @project_modules.each { |pm| @allowed.concat pm.allowed  }
        return @allowed.uniq
      end
      
      # Return denied actions/controllers
      def denied
        return @denied.uniq
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
      
      def menu(name, path=nil, options={}, &block)
        @menus << Menu.new(name, path, options, &block)
      end
      
      # Return allowed controllers
      def allowed
        @menus.each { |m| @allowed.concat m.allowed  }
        return @allowed.uniq
      end
      
      # Return the original name or try to humanize the symbol
      def human_name
        return @name.is_a?(Symbol) ? @name.to_s.humanize : @name
      end
      
      # Return a unique id for the given project module
      def uid
        @name.to_s.downcase.gsub(/[^a-z0-9]+/, '').gsub(/-+$/, '').gsub(/^-+$/, '')
      end
      
      # Return ExtJs Config for this project module
      def config
        options = @options.merge(:id => uid, :text => human_name)
        options.merge!(:menu => @menus.collect(&:config)) if @menus.size > 0
        options.merge!(:handler =>  ActiveSupport::JSON::Variable.new("function(){ Backend.app.load('#{url_for(@url.merge(:only_path => true))}') }")) if @url
        return options
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
        return @allowed.uniq
      end
      
      # Return the original name or try to humanize the symbol
      def human_name
        return @name.is_a?(Symbol) ? @name.to_s.humanize : @name
      end
      
      # Return a unique id for the given project module
      def uid
        @name.to_s.downcase.gsub(/[^a-z0-9]+/, '').gsub(/-+$/, '').gsub(/^-+$/, '')
      end
      
      # Return ExtJs Config for this menu
      def config
        options = @options.merge(:id => uid, :text => human_name)
        options.merge!(:menu => @items.collect(&:config)) if @items.size > 0
        options.merge!(:handler =>  ActiveSupport::JSON::Variable.new("function(){ Backend.app.load('#{url_for(@url.merge(:only_path => true))}') }")) if @url
        return options
      end
    end
    
    class AccessControlError < StandardError; end;
  end
end