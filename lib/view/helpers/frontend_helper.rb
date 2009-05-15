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
      end
    end
  end
end