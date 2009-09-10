require 'open-uri'
module Lipsiadmin
  module View
    module Helpers
      module FrontendHelper
        # Set the title of the page and append at the end the name of the project
        # Usefull for google & c.
        def title(text)
          content_for(:title) { text + " - #{AppConfig.project}" }
        end
        
        # Set the meta description of the page
        # Usefull for google & c.
        def description(text)
          content_for(:description) { text }
        end
        
        # Set the meta keywords of the page
        # Usefull for google & c.
        def keywords(text)
          content_for(:keywords) { text }
        end
        
        # Override the default image tag with a special option
        # <tt>resize</tt> that crop/resize on the fly the image
        # and store them in <tt>uploads/thumb</tt> directory.
        # 
        def image_tag(source, options = {})
          options.symbolize_keys!
          # We set here the upload path
          upload_path = "uploads/thumbs"
          # Now we can create a thumb on the fly
          if options[:resize]
            begin
              geometry     = options.delete(:resize)
              filename     = File.basename(source)
              new_filename = "#{geometry}_#{filename}".downcase.gsub(/#/, '')
              # Checking if we have just process them (we don't want to do the same job two times)
              if File.exist?("#{Rails.root}/public/#{upload_path}/#{new_filename}")
                options[:src] = "/#{upload_path}/#{new_filename}"
              else # We need to create the thumb
                FileUtils.mkdir("#{Rails.root}/tmp") unless File.exist?("#{Rails.root}/tmp")
                # We create a temp file of the original file
                # Notice that we can download them from an url! So this Image can reside anywhere on the web
                if source =~ /#{URI.regexp}/
                  tmp = File.new("#{Rails.root}/tmp/#{filename}", "w")
                  tmp.write open(source).read
                  tmp.close
                else # If the image is local
                  tmp = File.open(File.join("#{Rails.root}/public", path_to_image(source).gsub(/\?+\d*/, "")))
                end
                # Now we generate a thumb with our Thumbnail Processor (based on Paperclip)
                thumb = Lipsiadmin::Attachment::Thumbnail.new(tmp, :geometry => geometry).make
                # We check if our dir exists
                FileUtils.mkdir_p("#{Rails.root}/public/#{upload_path}") unless File.exist?("#{Rails.root}/public/#{upload_path}")
                # Now we put the image in our public path
                File.open("#{Rails.root}/public/#{upload_path}/#{new_filename}", "w") do |f|
                  f.write thumb.read
                end
                # Finally we return the new image path
                options[:src] = "/#{upload_path}/#{new_filename}"
              end
            rescue Exception => e
              options[:src] = path_to_image(source)
            ensure
              File.delete(tmp.path)   if tmp && tmp.path =~ /#{Rails.root}\/tmp/
              File.delete(thumb.path) if thumb
            end
          end

          if size = options.delete(:size)
            options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
          end

          options[:src] ||= path_to_image(source)
          options[:alt] ||= File.basename(options[:src], '.*').
                            split('.').first.to_s.capitalize

          if mouseover = options.delete(:mouseover)
            options[:onmouseover] = "this.src='#{image_path(mouseover)}'"
            options[:onmouseout]  = "this.src='#{image_path(options[:src])}'"
          end

          tag("img", options)
        end
      end
    end
  end
end