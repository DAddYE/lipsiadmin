class AttachmentGenerator < Rails::Generator::Base
  default_options :skip_migration => false
  
  def manifest    
    record do |m|
      unless options[:skip_migration]
        m.migration_template("migration.rb", "db/migrate", :migration_file_name => "create_attachments")
      end
      m.template('model.rb', 'app/models/attachment.rb')
      m.readme "../REMEMBER"      
    end
  end 


  protected
    def banner
      "Usage: #{$0} attachment [--skip-migration]"
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end
 
end