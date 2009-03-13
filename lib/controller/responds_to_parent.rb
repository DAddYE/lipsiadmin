module Lipsiadmin
  module Controller
    # Executes the response body as JavaScript in the context of the parent window.
    # 
    # Use this method of you are posting a form to a hidden IFRAME or if you would like
    # to use IFRAME base RPC.
    module RespondsToParent
      # Render an action to parent
      def render_to_parent(*options_for_render)
        responds_to_parent do
          # I don't use page.update for prevent dobule rendering 
          # and so we can save rendering time!
          source = render_to_string(*options_for_render)
          render :update do |page|
            page.call "Backend.app.update", source
          end
        end
      end
      # Redirect parent to a new url
      def redirect_parent_to(location)
        responds_to_parent do
          render :update do |page|
            page.load location, true
          end
        end
      end

      private
        def responds_to_parent(&block)
          yield
          # We're returning HTML instead of JS or XML now
          response.headers['Content-Type'] = 'text/html; charset=UTF-8'
          # Either pull out a redirect or the request body
          script =  location = erase_redirect_results ? "document.location.href = #{location.to_s.inspect}" : response.body
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
  end
end