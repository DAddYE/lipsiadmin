module Lipsiadmin
  module Mailer
    module PdfBuilder
      include Lipsiadmin::Utils::HtmlEntities
      
      # Path to the pd4ml jarfile        
      JARPATH = "../../resources"
      
      def render_pdf(template, body)
        # set the landescape
        landescape = (body[:landescape].delete || false)
        
        # encode the template
        input = encode_entities(render_message("/pdf/#{template}.html.haml", body))

        # search for stylesheet links and make their paths absolute.
        input.gsub!('<link href="/javascripts', '<link href="' + RAILS_ROOT + '/public/javascripts')
        input.gsub!('<link href="/stylesheets', '<link href="' + RAILS_ROOT + '/public/stylesheets')   

        # search for images src, append full-path.
        input.gsub!('src="/', 'src="' + RAILS_ROOT + '/public/')
        input.gsub!('url(','url('+RAILS_ROOT+'/public')
        #RAILS_DEFAULT_LOGGER.debug ('input: ' + input)

        cmd = "java -Xmx512m -Djava.awt.headless=true -cp pd4ml.jar:.:#{File.dirname(__FILE__)}/#{JARPATH} Pd4Ruby '#{input}' 950 A4 #{landescape}"

        output = %x[cd #{File.dirname(__FILE__)}/#{JARPATH} \n #{cmd}]

        # raise error if process returned false (ie: a java error)
        raise PdfError, "An unknonwn error occurred while generating pdf: #{cmd}" if $?.success? === false

        #return raw pdf binary-stream
        output                
      end
    end

    # Errors For PDF
    class PdfError < StandardError; end
  end
end