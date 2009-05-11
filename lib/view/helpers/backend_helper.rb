module Lipsiadmin
  module View
    module Helpers
      module BackendHelper
        # This method work like builtin Rails error_message_for but use an Ext.Message.        
        def simple_error_messages_for(*params)
          options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
          count   = objects.inject(0) {|sum, object| sum + object.errors.count }
          unless count.zero?
            error_messages = objects.map {|object| object.errors.full_messages.map {|msg| "<li>#{msg}</li>" } }
            return content_tag(:script, "Ext.Msg.show({
                        title:Backend.locale.messages.alert.title,
                        msg: '<ul>#{escape_javascript(error_messages.join)}</ul>',
                        buttons: Ext.Msg.OK,
                        minWidth: 400 
                      });", :type => Mime::JS)
          else
            ''
          end
        end
        
        # This method add tab for in your view
        def tab(name, padding=true, options={}, &block)
          options[:id]   ||= name.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/-+$/, '').gsub(/^-+$/, '')
          options[:style]  = "padding:10px;#{options[:style]}" if padding
          options[:title]  = name
          options[:tabbed] = true
          options[:class]  = "x-hide-display"
          concat content_tag(:div, capture(&block), options)
        end
        
        # Set the title of the page
        def title(title)
          content_tag(:script, "Backend.app.setTitle(#{title.to_json})", :type => Mime::JS)
        end
        
        # Store the location to come back from for example an extjs grid
        def back_to(location)
          content_tag(:script, "Backend.app.backTo(#{url_for(location)})", :type => Mime::JS)
        end
        
        # Generate the menu from the Lispiadmin::AccessControl
        def backend_menu
          config = current_account.maps.collect(&:project_modules)[0].collect(&:config)
          config << { :text => "Backend.locale.buttons.help".to_l, :handler => "function() { Backend.app.openHelp() }".to_l }
          return config.to_json
        end
        
        # Open a new windows that can contain a grid that you can reuse
        # 
        # The first argument name is used as the link text.
        # 
        # The second argument is the url where js of grid are stored.
        # 
        # The third argument is the name of the gird var usually gridPanel or editorGridPanel.
        # 
        # The four argument are callbacks that may be specified:
        # 
        # <tt>:before</tt>::     Called before request is initiated.
        # <tt>:update</tt>::     Called after user press +select+ button.
        #                        This call are performed in an handler where
        #                        you have access to two variables:
        #                        <tt>:win</tt>::  Backend.window
        #                        <tt>:selections</tt>::  Records selected in the grid
        # 
        #   # Generates: <a onclick="      
        #   #   new Backend.window({ 
        #   #     url: '/backend/categories.js', 
        #   #     grid: 'gridPanel',  
        #   #     listeners: {
        #   #       selected: function(win, selections){
        #   #         $('post_category_ids').value = selections.collect(function(s) { return s.id }).join(',');
        #   #         $('category_names').innerHTML = selections.collect(function(s) { return s.data['categories.name'] }).join(', ');
        #   #       }
        #   #     }
        #   #   }).show();
        #   #   return false;" href="#">Select a Category</a>
        # 
        #   open_grid "Select a Category", "/backend/categories.js", "gridPanel",
        #     :update => "$('post_category_ids').value = selections.collect(function(s) { return s.id }).join(',');" +
        #     "$('category_names').innerHTML = selections.collect(function(s) { return s.data['categories.name'] }).join(', ');"
        # 
        def open_grid(text, url, grid, options={})
          options[:before] = options[:before] + ";" if options[:before]
          javascript = <<-JAVASCRIPT
            #{options[:before]}
            new Backend.window({ 
              url: '#{url}', 
              grid: '#{grid}',  
              listeners: {
                selected: function(win, selections){
                  #{options[:update]}
                }
              }
            }).show()
          JAVASCRIPT
          link_to_function(text, javascript)
        end

        # Open a new windows that can contain a form that you can reuse
        # 
        # The first argument name is used as the link text.
        # 
        # The second argument is the url where html of form are stored.
        # 
        # The third argument are callbacks that may be specified:
        # 
        # <tt>:before</tt>::     Called before request is initiated.
        # <tt>:update</tt>::     Called after user press +save+ button.
        #                        This call are performed in an handler where
        #                        you have access to one variables:
        #                        <tt>:win</tt>::  Backend.window
        # 
        #   # Generates: <a onclick="  
        #   #     new Backend.window({ 
        #   #       url: '/backend/posts/'+$('comment_post_id').value+'/edit', 
        #   #       form: true,
        #   #       listeners: {
        #   #         saved: function(win){
        #   #           someFn();
        #   #         }
        #   #       }
        #   #     }).show();
        #   # return false;" href="#">Edit Post</a>
        #   open_form "Edit Post", "/backend/posts/'+$('comment_post_id').value+'/edit", :update => "someFn();"
        #   
        def open_form(text, url, options={})
          options[:before] = options[:before] + ";" if options[:before]
          javascript = <<-JAVASCRIPT
            #{options[:before]}
            new Backend.window({ 
              url: '#{url}', 
              form: true,
              listeners: {
                saved: function(win){
                  #{options[:update]}
                }
              }
            }).show()
          JAVASCRIPT
          link_to_function(text, javascript)
        end
        
        # This method call a remote_function and in the same time do a 
        # 
        #   Backend.app.mask()
        #
        # and when the function is complete 
        # 
        #   Backend.app.unmask()
        # 
        def link_to_remote_with_wait(name, options={}, html_options={})
          options[:complete] = "Backend.app.unmask();"
          options[:before]  = "Backend.app.mask('#{I18n.t('backend.javascripts.messages.wait.message')}')";
          link_to_function(name, remote_function(options), html_options || options.delete(:html))
        end

        # This method generates a new ExtJs BoxComponent.
        # 
        #   Examples:
        # 
        #     =box "My Title", "My Subtitle", :submit => true, :collapsible => true, :style => "padding:none", :start => :close do
        #       my content
        # 
        # Defaults:
        # 
        # * :submit => false
        # * :collapsible => false
        # * :start => :close
        # 
        def box(title=nil, subtitle=nil, options={}, &block)
          options[:style] ||= "width:99%;"
          options[:start] ||= :open
          return <<-HTML
            <div class="x-box" style="#{options[:style]}">
              <div class="x-box-tl">
                <div class="x-box-tr">
                  <div class="x-box-tc">&nbsp;</div>
                </div>
              </div>
              <div class="x-box-ml">
                <div class="x-box-mr">
                  <div class="x-box-mc">
                    <div id="x-body-title" style="#{"cursor:pointer" if options[:collapsible]}" onclick="#{"Backend.app.collapseBoxes(this);" if options[:collapsible]}">
                      #{"<h3 style=\"margin-bottom:0px;padding-bottom:0px;float:left;\">"+title+"</h3>" unless title.blank?}
                      #{"<div style=\"float:right\"><em>"+subtitle+"</em></div>" unless subtitle.blank?}
                      #{"<br class=\"clear\" />" if !title.blank? || !subtitle.blank?}
                      #{"<div style=\"font-size:0px\">&nbsp;</div>" if !title.blank? || !subtitle.blank?}
                    </div>
                    <div class="#{"x-box-collapsible" if options[:collapsible]}" style="width:99%;#{"display:none" if options[:collapsible] && options[:start] == :close}">
                      #{"<div style=\"font-size:10px\">&nbsp;</div>" if !title.blank? || !subtitle.blank?}
                      #{capture(&block)}
                      #{"<div style=\"text-align:right;margin-top:10px\">#{submit_tag(I18n.t("lipsiadmin.buttons.save"), :onclick=>"Backend.app.submitForm()")}</div>" if options[:submit]}
                    </div>
                  </div>
                </div>
              </div>
              <div class="x-box-bl">
                <div class="x-box-br">
                  <div class="x-box-bc">&nbsp;</div>
                </div>
              </div>
            </div>
          HTML
        end
        
      end
    end
  end
end