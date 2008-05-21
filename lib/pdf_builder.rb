module LipsiaSoft
  module PdfBuilder    
    # path to the pd4ml jarfile        
    JARPATH = "../resources"
    ###
    # file2pdf convert infile to pdf
    # @param {String} infile
    # @param {String} outfile
    # @return {Boolean} whether the process succeeded or not.
    #
    def file2pdf(infile, outfile, width = 950)
      # sanity-check infile exists           
      raise Error.new("input file '#{infile}' not found") if !FileTest.exist?(infile)
      # build & execute the shell command.        
      cmd = "java -jar #{File.dirname(__FILE__)}/#{JARPATH}/pd4ml.jar file:#{infile} #{outfile}"           
      # show command to user
      puts cmd
      # exec the cmd
      output = %x[cd #{File.dirname(__FILE__)} \n #{cmd}]
      # raise error if process returned false (ie: a java error)
      raise Error.new("An unknonwn error occurred while generating pdf: #{cmd}") if $?.success? === false
      # s'all good.  return true
      $?.success?
    end

    ###
    # render_to_pdf convert stream to pdf
    # @param {String} input
    # @param {Integer} html width
    # @param {Binary} pdf binary stream
    #
    def render_to_pdf(options = {}, width = 950)
      input = render_to_string(options)
      # search for stylesheet links and make their paths absolute.
      input.gsub!('<link href="/javascripts', '<link href="' + RAILS_ROOT + '/public/javascripts')
      input.gsub!('<link href="/stylesheets', '<link href="' + RAILS_ROOT + '/public/stylesheets')   
      
      # search for images src, append full-path.
      input.gsub!('src="/images', 'src="' + RAILS_ROOT + '/public/images')
      input.gsub!('url(','url('+RAILS_ROOT+'/public')
      #RAILS_DEFAULT_LOGGER.debug ('input: ' + input)

      cmd = "java -Xmx512m -Djava.awt.headless=true -cp pd4ml.jar:.:#{File.dirname(__FILE__)}/#{JARPATH} Pd4Ruby '#{input.gsub("'", "&#145;")}' #{width} A4"

      output = %x[cd #{File.dirname(__FILE__)}/#{JARPATH} \n #{cmd}]

      # raise error if process returned false (ie: a java error)
      raise Error.new("An unknonwn error occurred while generating pdf: #{cmd}") if $?.success? === false

      f = File.open('tmp/pdf.pdf', 'w') do |pdf|
        pdf << output
      end

      #return raw pdf binary-stream
      output                
    end
    ###
    # Error
    # PdfBuilder exception class
    #
    class Error < StandardError

    end
  end
end