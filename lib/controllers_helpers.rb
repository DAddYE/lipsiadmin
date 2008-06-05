module LipsiaSoft
  module ControllersHelpers
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::NumberHelper
    
    def render_javascript(file)
      render :inline => "<% content_for(:head) do %><script src=\"#{file}\" type=\"text/javascript\"></script><% end %>", :layout => "backend"
    end
    
    def lipsia_box(value)
      value ? "<img src=\"/images/backend/flag_green.gif\"/>" : "<img src=\"/images/backend/flag_red.gif\"/>"
    end
    
    def lipsia_image(image)
      if image
        return "<div class=\"link\"><a href=\"#\" onclick=\"Ext.Msg.alert('Image','<img src=\\'#{image.public_filename}\\' style=\\'height:#{image.height};width:#{image.width}\\' />');\" \"><img src=\"/images/backend/icons/image.png\" /></a></div>"
      end
    end
  end
end