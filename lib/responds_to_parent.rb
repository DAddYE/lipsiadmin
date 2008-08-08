module LipsiaSoft
  # Module containing the methods useful for child IFRAME to parent window communication
  module RespondsToParent
    
    def remove_element(id)
      render :update do |page|
        page.visual_effect :switch_off , "#{id}"
      end
    end
    
    def render_to_parent(obj, *options_for_render)
      responds_to_parent do
        render :update do |page|
          RAILS_DEFAULT_LOGGER.debug "--> #{obj.inspect}"
          page.show_errors_for obj
          page.update render(*options_for_render)
        end
      end
    end
    
    def redirect_to_parent(options={})
      title = options.delete(:title)
      message = options.delete(:message)
      case options
        when :back
          options = request.env["HTTP_REFERER"]
        when Hash
          options = url_for(options)
        else
          option = url_for(options)
      end
      responds_to_parent do
        render :update do |page|
          page.load_menu options
          page.show_message title, message
        end
      end
    end
    
    # Executes the response body as JavaScript in the context of the parent window.
    # Use this method of you are posting a form to a hidden IFRAME or if you would like
    # to use IFRAME base RPC.
    def responds_to_parent(&block)
      yield
    
      if performed?
        # We're returning HTML instead of JS or XML now
        response.headers['Content-Type'] = 'text/html; charset=UTF-8'
      
        # Either pull out a redirect or the request body
        script =  if location = erase_redirect_results
                    "document.location.href = #{location.to_s.inspect}"
                  else
                    response.body
                  end
        # Escape quotes, linebreaks and slashes, maintaining previously escaped slashes
        # Suggestions for improvement?
        script = (script || '').
          gsub('\\', '\\\\\\').
          gsub(/\r\n|\r|\n/, '\\n').
          gsub(/['"]/, '\\\\\&').
          gsub('</script>','</scr"+"ipt>')
        # Clear out the previous render to prevent double render
        erase_results
        # Eval in parent scope and replace document location of this frame 
        # so back button doesn't replay action on targeted forms
        # loc = document.location to be set after parent is updated for IE
        # with(window.parent) - pull in variables from parent window
        # setTimeout - scope the execution in the windows parent for safari
        # window.eval - legal eval for Opera
        render :text => "<html><body><script type='text/javascript' charset='utf-8'>
          var loc = document.location;
          with(window.parent) { setTimeout(function() { window.eval('#{script}'); loc.replace('about:blank'); }, 1) } 
        </script></body></html>"
      end
    end
    alias respond_to_parent responds_to_parent
  end
end