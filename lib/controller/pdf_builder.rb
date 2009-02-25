module Lipsiadmin
  module Controller
    # This module convert a string/controller to a pdf through Pd4ml java library (included in this plugin)
    # 
    # For generate a pdf you can simply do
    #   
    #     script/generate pdf invoice
    # 
    # then edit your template /app/views/pdf/invoice.html.haml
    # 
    # Then in any of your controllers add some like this:
    # 
    #   def generate_pdf_invoice
    #     render_pdf :invoice, 'invoice_file.pdf'
    #   end
    #   
    module PdfBuilder
      include Lipsiadmin::Utils::HtmlEntities
      
      # Path to the pd4ml jarfile        
      JARPATH = "../../resources"

      # Convert a stream to pdf, the template must be located in app/view/pdf/yourtemplate.pdf.erb
      def render_pdf(template, filename, landescape = false)
        # encode the template
        input = encode_entities(render(:template => "/pdf/#{template}.html.haml", :layout => "print"))
        
        # search for stylesheet links and make their paths absolute.
        input.gsub!('<link href="/javascripts', '<link href="' + RAILS_ROOT + '/public/javascripts')
        input.gsub!('<link href="/stylesheets', '<link href="' + RAILS_ROOT + '/public/stylesheets')   

        # search for images src, append full-path.
        input.gsub!('src="/', 'src="' + RAILS_ROOT + '/public/')
        input.gsub!('url(','url('+RAILS_ROOT+'/public')

        cmd = "java -Xmx512m -Djava.awt.headless=true -cp pd4ml.jar:.:#{File.dirname(__FILE__)}/#{JARPATH} Pd4Ruby '#{input}' 950 A4 #{landescape}"

        output = %x[cd #{File.dirname(__FILE__)}/#{JARPATH} \n #{cmd}]

        # raise error if process returned false (ie: a java error)
        raise PdfError, "An unknonwn error occurred while generating pdf: cd #{File.dirname(__FILE__)}/#{JARPATH} #{cmd}" if $?.success? === false

        #return raw pdf binary-stream
        options  = { :filename => filename, :type => 'application/pdf' }
        options[:disposition] = "inline" if Rails.env == "development"
        send_data(output, options)
      end

      # Errors For PDF
      class PdfError < StandardError#:nodoc:
      end
    end
  end
end