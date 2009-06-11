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
        # First argument is the name and title of the tab, an interesting thing wose that this helper 
        # try to translate itself to your current locale ex:
        # 
        #   # Look for: I18n.t("backend.tabs.settings", :default => "Settings")
        #   tab :settings do
        #     ...
        # 
        # The second argument specify if is necessary 10px of padding inside the tab, default is +true+
        # 
        # Third argument is an hash that accepts:
        # 
        # <tt>:id</tt>::    The id of the tab
        # <tt>:style</tt>:: Custom style of the tab
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
        #   # Look for: I18n.t("backend.titles.welcome_here", :default => "Welcome Here")
        #   title :welcome_here
        # 
        def title(title)
          title = I18n.t("backend.titles.#{title.to_s.downcase}", :default => title.to_s.humanize)
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
        #   #   Attribute not translated
        #   human_name_for :account, :name
        #   human_name_for :account, :surname
        #   human_name_for :account, :role
        #   human_name_for :account, :attribute_not_translated
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
          config = AccountAccess.maps_for(current_account).collect(&:project_modules).flatten.uniq.collect(&:config)
          config << { :text => I18n.t("backend.menus.help", :default => "Help"), :handler => "function() { Backend.app.openHelp() }".to_l }
          return config.to_json
        end

        # Returns html for upload one image or generic file.
        # 
        # Options can be one of the following:
        # 
        # <tt>:image</tt>::     Indicate if the attachments are ONLY images.
        # 
        # Examples:
        # 
        #   class Category < ActiveRecord::Base
        #     has_one_attachments    :file,   :dependent => :destroy
        #   ...
        # 
        # Then in our view we can simply add this:
        # 
        #   attachments_tag(:category, :file)
        # 
        # Remember that al labels can be translated. See Locales for Backend.
        # 
        def attachment_tag(object_name, method, options={})
          variable = instance_variable_get("@#{object_name}")
          html     = []
          html    << '<!-- Generated from Lipsiadmin -->'
          html    << '<ul id="' + "#{method}-order" + '" class="label">'

          if attachment = variable.send(method)
            # Create first the remove link
            remove_link = link_to_remote(tl(:remove), :url => "/backend/attachments/#{attachment.id}", 
                                                      :method => :delete, 
                                                      :success => "$('#{method}_#{attachment.id}').remove();")

            if options[:image]
              fstyle  = "float:left;margin:5px;margin-left:0px;"
              fclass  = "box-image"
              ftag    = '<div>' + image_tag(attachment.url(:thumb)) + '</div>'
              ftag   += '<div style="text-align:center;padding:5px;cursor:pointer">'
              ftag   += '  ' + remove_link
              ftag   += '</div>'
            else
              fstyle  = "padding:5px;border-bottom:1px solid #DDE7F5;"
              fclass  = "box-file"
              ftag    = '<div style="float:left;cursor:pointer">'
              ftag   += ' ' + link_to(attachment.attached_file_name, attachment.url) + ' ' + number_to_human_size(attachment.attached_file_size)
              ftag   += '</div>'
              ftag   += '<div style="float:right;cursor:pointer">'
              ftag   += '  ' + remove_link
              ftag   += '</div>'
              ftag   += '<br style="clear:both" />'
            end

            html << '<li id="' + "#{method}_#{attachment.id}" + '" class="' + fclass + '" style="' + fstyle + '">'
            html << ' ' + ftag
            html << '</li>'
          end # End of Loop

          html << '</ul>'
          html << '<br style="clear:both" />'

          flbl = options[:image] ? :upload_image : :upload_file
          html << '<div class="label-title">' + tl(flbl) + '</div>'
          html << '<table>'
          rowa  = '  <tr class="attachment">'
          rowa << '    <td>' + human_name_for(:attachment, :attached_file_name) + '</td>'
          rowa << '    <td>' + file_field_tag("#{object_name}[#{method}_attributes][file]", :style => "width:250px") + '</td>'
          rowa << '  </tr>'
          html << rowa
          html << '</table>'
          html.join("\n")
        end
        
        # Returns html for upload multiple images or generic files.
        # 
        # Options can be one of the following:
        # 
        # <tt>:image</tt>::     Indicate if the attachments are ONLY images.
        # <tt>:order</tt>::     Indicate if user can order files.
        # 
        # Examples:
        # 
        #   class Category < ActiveRecord::Base
        #     has_many_attachments    :images,   :dependent => :destroy
        #     validates_attachment_content_type_for :images, /^image/
        #   ...
        # 
        # Then in our view we can simply add this:
        # 
        #   attachments_tag(:category, :images, :image => true, :order => true)
        # 
        # Remember that al labels can be translated. See Locales for Backend.
        # 
        def attachments_tag(object_name, method, options={})
          variable = instance_variable_get("@#{object_name}")
          html     = []
          html    << '<!-- Generated from Lipsiadmin -->'
          html    << '<ul id="' + "#{method}-order" + '" class="label">'

          for attachment in variable.send(method).all(:order => :position)
            # Create first the remove link
            remove_link = link_to_remote(tl(:remove), :url => "/backend/attachments/#{attachment.id}", 
                                                      :method => :delete, 
                                                      :success => "$('#{method}_#{attachment.id}').remove();")

            if options[:image]
              fstyle  = "float:left;margin:5px;margin-left:0px;"
              fstyle += "cursor:move;" if options[:order]
              fclass  = "box-image"
              ftag    = '<div>' + image_tag(attachment.url(:thumb)) + '</div>'
              ftag   += '<div style="text-align:center;padding:5px;cursor:pointer">'
              ftag   += '  ' + remove_link
              ftag   += '</div>'
            else
              fstyle  = "padding:5px;border-bottom:1px solid #DDE7F5;"
              fstyle += "cursor:move;" if options[:order]
              fclass  = "box-file"
              ftag    = '<div style="float:left;cursor:pointer">'
              ftag   += ' ' + link_to(attachment.attached_file_name, attachment.url) + ' ' + number_to_human_size(attachment.attached_file_size)
              ftag   += '</div>'
              ftag   += '<div style="float:right;cursor:pointer">'
              ftag   += '  ' + remove_link
              ftag   += '</div>'
              ftag   += '<br style="clear:both" />'
            end

            html << '<li id="' + "#{method}_#{attachment.id}" + '" class="' + fclass + '" style="' + fstyle + '">'
            html << ' ' + ftag
            html << '</li>'
          end # End of Loop

          html << '</ul>'
          html << '<br style="clear:both" />'

          if options[:order]
            constraint = options[:image] ? "horizontal" : "vertical"
            html << '<div id="' + "#{method}-message" + '" style="padding:5px">&nbsp;</div>'
            html << sortable_element("#{method}-order", :url => "/backend/attachments/order", :update => "#{method}-message", :constraint => constraint,
                                                        :complete => visual_effect(:highlight, "#{method}-message", :duration => 0.5))
          end

          flbl = options[:image] ? :upload_images : :upload_files
          html << '<div class="label-title">'+ tl(flbl) +'</div>'
          html << '<table>'
          rowa  = '  <tr class="attachment">'
          rowa << '    <td>' + human_name_for(:attachment, :attached_file_name) + '</td>'
          rowa << '    <td>' + file_field_tag("#{object_name}[#{method}_attributes][][file]", :style => "width:250px") + '</td>'
          rowa << '    <td>' + link_to_function(tl(:remove), "this.up('.attachment').remove()") + '</td>'
          rowa << '  </tr>'
          html << rowa
          html << ' <tr id="' + "add-#{method}" + '">'
          html << '  <td colspan="2">&nbsp;</td>'
          html << '  <td style="padding-top:15px">'
          html << '     ' + link_to_function(tl(:add)) { |page| page.insert_html(:before, "add-#{method}", rowa) }
          html << '  </td>'
          html << ' </tr>'
          html << '</table>'
          html.join("\n")
        end

        # Build a new windows that can contain an existent grid
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
        #   build_grid "Select a Category", "/backend/categories.js", "gridPanel",
        #     :update => "$('post_category_ids').value = selections.collect(function(s) { return s.id }).join(',');" +
        #     "$('category_names').innerHTML = selections.collect(function(s) { return s.data['categories.name'] }).join(', ');"
        # 
        def build_grid(text, url, grid, options={})
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
          link_to_function(text, javascript.gsub(/\n|\s+/, " "))
        end
        alias_method :open_grid, :build_grid

        # Open a Standard window that can contain a standard existent grid
        # 
        # Options can be one of the following:
        # 
        # <tt>:grid</tt>::       The name of the grid var. Default "gridPanel"
        # <tt>:url</tt>::        The url where the grid is stored. Default is autogenerated.
        # <tt>:name</tt>::       The name of the link that open the window grid. Default a image.
        # 
        #   # Generates: <a onclick="
        #   #   new Backend.window({ 
        #   #     url: '/backend/suppliers.js', 
        #   #     grid: 'gridPanel', 
        #   #     listeners: {  
        #   #       selected: function(win, selections){  
        #   #         $('warehouse_supplier_id').value = selections.first().id; 
        #   #         $('warehouse_supplier_name').innerHTML = selections.first().data['suppliers.name']  
        #   #       }  
        #   #     }  
        #   #   }).show(); return false;">
        #   # <img alt="New" src="/images/backend/new.gif?1242655402" style="vertical-align:bottom" /></a>
        #   # <input id="warehouse_supplier_id" name="warehouse[supplier_id]" type="hidden" value="16" />
        #   open_standard_grid :warehouse, :supplier, :id, :name
        #
        def open_standard_grid(object_name, ext_object, value, display, options={})
          current_value       = instance_variable_get("@#{object_name}").send(ext_object).send(display) rescue "Nessuno"
          value_field         = value.to_s.downcase == "id" ? "id" : "data['#{ext_object.to_s.pluralize}.#{value}']"
          options[:grid]    ||= "gridPanel"
          options[:url]     ||= "/backend/#{ext_object.to_s.pluralize}.js"
          options[:name]    ||= image_tag("backend/new.gif", :style => "vertical-align:bottom")
          update_function     = "$('#{object_name}_#{ext_object}_#{value}').value = selections.first().#{value_field}; " + 
                                "$('#{object_name}_#{ext_object}_#{display}').innerHTML = selections.first().data['#{ext_object.to_s.pluralize}.#{display}']"

          content_tag(:span, current_value, :id => "#{object_name}_#{ext_object}_#{display}" ) + ' ' +
          build_grid(options[:name], options[:url], options[:grid], :update => update_function) +
          hidden_field(object_name, "#{ext_object}_#{value}")
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
          link_to_function(text, javascript.gsub(/\n/, " "))
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