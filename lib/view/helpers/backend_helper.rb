module Lipsiadmin
  module View
    module Helpers
      module BackendHelper
        # This method work like builtin Rails error_message_for but use an Ext.Message.show({..})
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
        
        # This method add tab for in your view.
        # 
        # +name+ is the name and title of the tab, an interesting thing wose that this helper 
        # try to translate itself to your current locale ex:
        # 
        #   # Look for: I18n.t("backend.tabs.settings") in config/locales/backend/yourlocale.yml
        #   tab :settings do
        #     ...
        # 
        # +padding+ specify if is necessary 10px of padding inside the tab, default is +true+
        # 
        # +options+ accepts:
        #   <tt>:id</tt>::    The id of the tab
        #   <tt>:style</tt>:: Custom style of the tab
        # 
        def tab(name, padding=true, options={}, &block)
          options[:id]    ||= name.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/-+$/, '').gsub(/^-+$/, '')
          options[:style] ||= "padding:10px;#{options[:style]}" if padding
          options[:title]  = I18n.t("backend.tabs.#{name.to_s.downcase}", :default => name.to_s.humanize)
          options[:tabbed] = true
          options[:class]  = "x-hide-display"
          concat content_tag(:div, capture(&block), options)
        end
        
        # Set the title of the page.
        # 
        # An interesting thing wose that this helper 
        # try to translate itself to your current locale ex:
        # 
        #   # Look for: I18n.t("backend.titles.welcome_here") in config/locales/backend/yourlocale.yml
        #   title :welcome_here
        # 
        def title(title)
          title = I18n.t("backend.titles.#{title.to_s.downcase}", :default => title)
          content_tag(:script, "Backend.app.setTitle(#{title.to_json})", :type => Mime::JS)
        end
        
        # Get the title for grids of the specified model based on your
        # current locale.
        # 
        # The locale file for this translation is located: config/locales/backend
        # 
        #   # Generate: List all Accounts
        #   list_title_for(Account)
        # 
        #   # Generate: List all My Accounts
        #   list_title_for("My Accounts")
        # 
        def list_title_for(text)
          I18n.t("backend.general.list", :model => text.is_a?(String) ? text : text.send(:human_name))
        end
        
        # Get the title for edit action of a form based on your current locale
        # 
        # The locale file for this translation is located: config/locales/backend
        # 
        #   # Generate: Edit Account 18
        #   edit_title_for(Account, @account.id)
        #   
        #   # Generate: Edit My Account Foo Bar
        #   edit_title_for("My Account", @account.full_name)
        # 
        def edit_title_for(text, value)
          title I18n.t("backend.general.editForm", :model => text.is_a?(String) ? text : text.send(:human_name), :value => value)
        end

        # Get the title for new action of a form based on your current locale
        # 
        # The locale file for this translation is located: config/locales/backend
        # 
        #   # Generate: New Account
        #   new_title_for(Account)
        #   
        #   # Generate: New My Account
        #   new_title_for("My Account")
        # 
        def new_title_for(text)
          title I18n.t("backend.general.newForm", :model => text.is_a?(String) ? text : text.send(:human_name))
        end
        
        # Try to translate the given word
        # 
        #   # Generate: I18n.t("backend.labels.add", :default => "Add")
        #   tl("Add")
        # 
        def translate_label(text)
          I18n.t("backend.labels.#{text.to_s.downcase.gsub(/\s/, "_")}", :default => text.to_s.humanize)
        end
        alias_method :tl, :translate_label

        # Try to translate the given pharse
        # 
        #   # Generate: I18n.t("backend.labels.lipsiadmin_is_beautifull", :default => "Lipsiadmin is beautifull")
        #   tt("Lipsiadmin is beautifull")
        # 
        def translate_text(text)
          I18n.t("backend.texts.#{text.to_s.downcase.gsub(/\s/, "_")}", :default => text.to_s.humanize)
        end
        alias_method :tt, :translate_text
        
        # Return the translated attribute based on your current locale
        # 
        #   # In config/locales/backend/models/en.yml
        #   en:
        #     activerecord:
        #       attributes:
        #         account:
        #           name: "Account Name"
        #           suranme: "Custom Title For Surname"
        #           role: "Im a"
        #   
        #   # Generates: 
        #   #   Account Name
        #   #   Custom Title For Surname
        #   #   Im a
        #   human_name_for :account, :name
        #   human_name_for :account, :surname
        #   human_name_for :account, :role
        # 
        def human_name_for(instance, method)
          I18n.t("activerecord.attributes.#{instance}.#{method}", :default => method.to_s.humanize)
        end
        
        # Store the location to come back from for example an extjs grid
        def back_to(location)
          content_tag(:script, "Backend.app.backTo(#{url_for(location)})", :type => Mime::JS)
        end
        
        # Generate the menu from the Lispiadmin::AccessControl
        def backend_menu
          config = current_account.maps.collect(&:project_modules)[0].collect(&:config)
          config << { :text => I18n.t("backend.menus.help", :default => "Help"), :handler => "function() { Backend.app.openHelp() }".to_l }
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