class FrontendGenerator < Rails::Generator::Base
  
  def manifest

    record do |m|
      m.create_all("controllers", "app/controllers")
      m.create_all("helpers", "app/helpers")
      m.create_all("layouts", "app/views/layouts")
      m.create_all("stylesheets", "public/stylesheets")
      m.create_all("views", "app/views")
  
      m.readme "../REMEMBER"      
    end
  end
  
  protected
    def banner
      "Usage: #{$0} frontend"
    end
end