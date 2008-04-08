class LipsiadminGenerator < Generator::Lipsiadmin
  def manifest
    # Routes
    path = File.join(RAILS_ROOT, "config/routes.rb")
    
    text = <<-ROUTES 
  map.namespace(:backend, :path_prefix => :admin) do |backend|
    backend.resources :accounts, :collection => { :list => :any }
    backend.resources :menuitems, :collection => { :list => :any }
    backend.resources :sessions
  end

  map.backend     '/admin', :controller => 'backend/base', :action => 'index'
  map.activation  '/admin/accounts/activate/:activation_code', :controller => 'backend/accounts', :action=>'activate'
  map.connect     '/javascripts/:action.:format', :controller => 'javascripts'
  ROUTES
    
    application_src = File.read(path)
    
    unless application_src.include?(text)
      head = "ActionController::Routing::Routes.draw do |map|"
      application_src.sub!(head, head + "\n" + text)
      File.open(path, 'w') {|f| f.write(application_src) }
    end
    # Robot
    path = File.join(RAILS_ROOT, "public/robots.txt")
    
    text = "User-agent: *\nDisallow: /admin\n"
    
    application_src = File.read(path)
    
    unless application_src.include?(text)
      application_src = text
      File.open(path, 'w') {|f| f.write(application_src) }
    end
    
    record do |m|
      create_all(m, "controllers", "app/controllers/")
      create_all(m, "helpers", "app/helpers/")
      create_all(m, "images", "public/images")
      create_all(m, "javascripts", "public/javascripts")
      create_all(m, "stylesheets", "public/stylesheets")
      create_all(m, "layouts", "app/views/layouts/")
      create_all(m, "migrations", "db/migrate")
      create_all(m, "models", "app/models")
      create_all(m, "views", "app/views/")
      create_all(m, "config", "config")
      m.readme "../REMEMBER"      
    end
  end

  protected
    def banner
      "Usage: #{$0} generate lipsiadmin"
    end
end