class BackendGenerator < Rails::Generator::Base

  def manifest
    # Initial routes
    routes = <<-ROUTES
  map.namespace(:backend) do |backend|
    backend.resources :accounts
    backend.resources :sessions
  end

  map.backend                 '/backend', :controller => 'backend/base', :action => 'index'
  map.connect                 '/javascripts/:action.:format', :controller => 'javascripts'
  ROUTES
  
    lipsiadmin_task = <<-EOF
begin
  gem 'lipsiadmin'
  require 'lipsiadmin_tasks'
rescue Gem::LoadError
end
    EOF
    
    record do |m|
      m.directory("app/views/exceptions")
      
      m.append("config/routes.rb", routes, "ActionController::Routing::Routes.draw do |map|")
      m.append("public/robots.txt", "User-agent: *\nDisallow: /backend")
      m.append("RakeFile", lipsiadmin_task)
      
      m.create_all("controllers", "app/controllers")
      m.create_all("helpers", "app/helpers")
      m.create_all("images", "public/images")
      m.create_all("javascripts", "public/javascripts")
      m.create_all("stylesheets", "public/stylesheets")
      m.create_all("layouts", "app/views/layouts")
      m.create_all("models", "app/models")
      m.create_all("views", "app/views")
      m.create_all("config", "config")
      m.create_all("test", "test")
      
      # Using this for prevent raising errors
      migration = Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_create_accounts.rb$/)
      if migration.empty?
        m.migration_template("migrations/create_accounts.rb", "db/migrate", :migration_file_name => "create_accounts")
      else
        logger.exists migration.first
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