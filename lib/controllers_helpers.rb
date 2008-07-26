module LipsiaSoft
  module ControllersHelpers
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::NumberHelper
    
    def render_javascript(file)
      render :text => "<script src=\"#{file}\" type=\"text/javascript\"></script>"
    end
  end
end