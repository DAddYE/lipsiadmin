module Lipsiadmin
  module Controller
    # This module convert a string/controller to a pdf through Pd4ml java library (included in this plugin)-
    # 
    # PD4ML is a powerful PDF generating tool that uses HTML and CSS (Cascading Style Sheets) as page layout 
    # and content definition format. Written in 100% pure Java, it allows users to easily add PDF generation 
    # functionality to end products.
    # 
    # Remember to install jdk ex: yum install java-1.6.0-openjdk-devel.i386
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
    # Possible options are:
    # 
    # * landescape, default it's false
    # * send_data,  default it's true
    # 
    # Lipsiadmin include a trial fully functional evaluation version, but if you want buy it, 
    # go here: http://pd4ml.com/buy.htm and then put your licensed jar in a directory in your
    # project then simply calling this:
    # 
    #   Lipsiadmin::Utils::PdfBuilder.jars_path = "here/is/my/licensed/pd4ml"
    #   Lipsiadmin::Utils::PdfBuilder.view_path = "keep/template/in/other/path"
    # 
    # you can use your version without any problem.
    # 
    # By default Lipsiadmin will look into your "vendor/pd4ml" and if:
    # 
    # * pd4ml.jar
    # * ss_css2.jar
    # 
    # are present will use it
    # 
    module PdfBuilder
      include Lipsiadmin::Utils::HtmlEntities
      
      # # Convert a stream to pdf, the template must be located in app/view/pdf/yourtemplate.pdf.erb
      def render_pdf(template, filename=nil, options={})

        # path to the pd4ml jarfile
        jars_path = Lipsiadmin::Utils::PdfBuilder.jars_path
        # path to our templates
        view_path = Lipsiadmin::Utils::PdfBuilder.view_path
        
        options[:landescape]   =  options[:landescape] ? "LANDESCAPE" : "PORTRAIT"
        options[:send_data]  ||= !filename.blank?
        
        # try to find erb extension
        ext = File.exist?("#{view_path}/#{template}.html.erb") ? "erb" : "haml"
        
        # encode the template
        input = encode_entities(render(:template => "#{view_path}/#{template}.html.#{ext}", :layout => false))
        
        # search for stylesheet links and make their paths absolute.
        input.gsub!('<link href="/javascripts', '<link href="' + view_path + '/../../../public/javascripts')
        input.gsub!('<link href="/stylesheets', '<link href="' + view_path + '/../../../public/stylesheets')   

        # search for images src, append full-path.
        input.gsub!('src="/', 'src="' + RAILS_ROOT + '/public/')
        input.gsub!('url(','url('+RAILS_ROOT+'/public')

        # write our temp file
        t = Tempfile.new("pd4ml.html", "#{Rails.root}/tmp")
        t.binmode
        t.write(input)
        t.flush
        
        # build the command
        class_path = "#{jars_path}/pd4ml.jar:.:#{jars_path}"
        class_path = "\"#{jars_path}/pd4ml.jar\";\"#{jars_path}\"" if RUBY_PLATFORM =~ /mswin/
        cmd = "cd #{Lipsiadmin::Utils::PdfBuilder.pd4ruby_path} && java -Xmx512m -Djava.awt.headless=true -cp #{class_path} Pd4Ruby --file \"#{t.path}\" --width 950 --orientation #{options[:landescape]} 2>&1"
        
        # grep the output
        output = IO.popen(cmd) { |s| s.read }

        # raise error if process returned false (ie: a java error)
        raise PdfError, "An unknonwn error occurred while generating pdf" if $?.exitstatus == 127
        
        # return raw pdf binary-stream
        if options[:send_data]
          pdf_options  = { :filename => filename, :type => 'application/pdf' }
          pdf_options[:disposition] = "inline" if Rails.env == "development"
          send_data(output, pdf_options) 
        else
          erase_results
          output
        end
      end

      # Errors For PDF
      class PdfError < StandardError#:nodoc:
      end
    end
  end
end