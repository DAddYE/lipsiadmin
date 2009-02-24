class BackendGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    runtime_args = ["none"].concat(runtime_args) # Skip usage
    super
  end
  
  def manifest
    # Initial routes
    routes = <<-ROUTES
  map.namespace(:backend) do |backend|
    backend.resources :accounts
    backend.resources :sessions
  end

  map.backend                 '/backend', :controller => 'backend/base', :action => 'index'
  map.activation              '/backend/accounts/activate/:activation_code', :controller => 'backend/accounts', :action=>'activate'
  map.refresh_project_modules '/backend/accounts/refresh_project_modules', :controller => 'backend/accounts', :action=>'refresh_project_modules'
  map.connect                 '/javascripts/:action.:format', :controller => 'javascripts'
  ROUTES
    
    record do |m|
      m.directory("app/views/exceptions")
      
      m.append("config/routes.rb", routes, "ActionController::Routing::Routes.draw do |map|")
      m.append("public/robots.txt", "User-agent: *\nDisallow: /backend")
      
      m.create_all("controllers", "app/controllers")
      m.create_all("helpers", "app/helpers")
      m.create_all("images", "public/images")
      m.create_all("javascripts", "public/javascripts")
      m.create_all("stylesheets", "public/stylesheets")
      m.create_all("layouts", "app/views/layouts")
      m.create_all("models", "app/models")
      m.create_all("views", "app/views")
      m.create_all("config", "config")
      
      # Using this for prevent raising errors
      if m.migration_exists?("create_accounts")
        logger.exists "db/migrate/create_accounts.rb"
      else
        m.migration_template("migrations/create_accounts.rb", "db/migrate", :migration_file_name => "create_accounts")
      end
      
      %w(404 422 500).each do |page|
        m.template("exceptions/template.html.haml", "app/views/exceptions/#{page}.html.haml", :assigns => { :status_code => page })
      end
      
      m.readme "../REMEMBER"      
    end
  end

  protected
    def banner
      "Usage: #{$0} backend"
    end
end