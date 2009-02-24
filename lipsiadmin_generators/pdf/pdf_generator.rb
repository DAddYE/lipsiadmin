class PdfGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    runtime_args = ["pdf"].concat(runtime_args) # Skip usage
    super
  end
  
  def manifest
    record do |m|
      # Copy Stylesheets
      m.create_all("stylesheets", "public/stylesheets")

      # Layout and Views
      m.directory "app/views/pdf"
      m.directory "app/views/layouts"
      
      # Layout
      m.template 'layout.html.erb', 'app/views/layouts/print.html.erb'

      # View template for each action.
      actions.each do |action|
        m.template 'view.html.haml', "app/views/pdf/#{action}.html.haml",
          :assigns => { :action => action }
      end
      
      m.puts remember
    end
  end


  protected
    def banner
      "Usage: #{$0} pdf action"
    end
    
    def remember
      <<-MESSAGE

==============================================================================================

  Please remember to add in your controller(s) some like:
  
#{actions.collect { |a| 
"    def generate_pdf_#{a}
      render_pdf :#{a}, '#{a}_file.pdf'
    end" }.join("\n\n")}

==============================================================================================
      MESSAGE
    end    
end