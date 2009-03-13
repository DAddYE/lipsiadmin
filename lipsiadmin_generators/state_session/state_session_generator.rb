class StateSessionGenerator < Rails::Generator::Base
  default_options :skip_migration => false
  
  def manifest    
    record do |m|
      # Controller class, functional test, helper, and views.
      m.template 'controller.rb', 'app/controllers/backend/state_sessions_controller.rb'
      m.template 'functional_test.rb', 'test/functional/backend/state_sessions_controller_test.rb'
      
      unless options[:skip_migration]
        m.migration_template("migration.rb", "db/migrate", :migration_file_name => "create_state_sessions")
      end
      
      m.template('model.rb', 'app/models/state_session.rb')
      # Adding a new route
      m.append("config/routes.rb", "    backend.resources :state_sessions", "map.namespace(:backend) do |backend|")
      m.readme "../REMEMBER"      
    end
  end 


  protected
    def banner
      "Usage: #{$0} state_session_migration [--skip-migration]"
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end
 
end