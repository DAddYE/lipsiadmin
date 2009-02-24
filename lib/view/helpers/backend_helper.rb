module Lipsiadmin
  module View
    module Helpers
      module BackendHelper
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
    
        def tab(name, padding=true, options={}, &block)
          options[:style] = "padding:10px;#{options[:style]}" if padding
          options[:id] ||= name.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/-+$/, '').gsub(/^-+$/, '')
          concat content_tag(:div, capture(&block), { :id => options[:id], :class => "x-hide-display", :style => options[:style], :tabbed => true, :title => name })
        end
        
        def title(title)
          content_tag(:script, "Backend.app.setTitle(#{title.to_json})", :type => Mime::JS)
        end
        
        def back_to(location)
          content_tag(:script, "Backend.app.backTo(#{url_for(location)})", :type => Mime::JS)
        end
        
        def backend_menu
          config = current_account.maps.collect(&:project_modules)[0].collect(&:config)
          config << { :text => "Backend.locale.buttons.help".to_l, :handler => "function() { Backend.app.openHelp() }".to_l }
          return config.to_json
        end

        def open_window(url, value, display, render_value_to, render_display_to)
          link_to_function(image_tag("backend/new.gif", :style=>"vertical-align:bottom"), 
            "Backend.window.open({url:'#{url}', display:'#{display}', value:'#{value}', displayField:'#{render_display_to}', valueField:'#{render_value_to}'})")
        end

        def link_to_remote_with_wait(name, options={}, html_options={})
          options[:complete] = "Backend.app.unmask();"
          options[:before]  = "Backend.app.mask('#{I18n.t('backend.messages.wait.message')}')";
          link_to_function(name, remote_function(options), html_options || options.delete(:html))
        end

        def box(title=nil, subtitle=nil, options={}, &block)
          return <<-HTML
            <div class="x-box" style="width:99%">
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
                    <div class="#{"x-box-collapsible" if options[:collapsible]}" style="width:99%;#{"display:none" if options[:collapsible]}">
                      #{"<div style=\"font-size:10px\">&nbsp;</div>" if !title.blank? || !subtitle.blank?}
                      #{capture(&block)}
                      #{"<div style=\"text-align:right;margin-top:10px\">#{submit_tag("Salva", :onclick=>"Backend.app.submitForm()")}</div>" if options[:submit]}
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