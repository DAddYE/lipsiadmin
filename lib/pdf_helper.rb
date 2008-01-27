module LipsiaSoft
  module PdfHelper
    # Makes a pdf, returns it as data...
    def make_pdf(template_path, landscape=false)
      prince = Prince.new()
      # Sets style sheets on PDF renderer.
      prince.add_style_sheets(
        "#{RAILS_ROOT}/public/stylesheets/print.css"
      )
      # Render the estimate to a big html string.
      # Set RAILS_ASSET_ID to blank string or rails appends some time after
      # to prevent file caching, fucking up local - disk requests.
      ENV["RAILS_ASSET_ID"] = ''
      html_string = render_to_string(:template => template_path, :layout => 'print')
      # Make all paths relative, on disk paths...
      html_string.gsub!("src=\"", "src=\"#{RAILS_ROOT}/public")
      html_string.gsub!("url(","url(#{RAILS_ROOT}/public")
      # Send the generated PDF file from our html string.
      return prince.pdf_from_string(html_string)
    end

    # Makes and sends a pdf to the browser
    # :disposition => 'inline'
    def make_and_send_pdf(template_path, pdf_name, landscape=false)
      send_data(
        make_pdf(template_path, landscape),
        :filename => pdf_name,
        :type => 'application/pdf'#, :disposition => "inline"
      ) 
    end
  end
end