module LipsiaSoft
  module LipsiAdminHelper
    def page(options={}, &block)
      head = options[:text] ? true : false
      tabs = (options[:tabs] && options[:tabs][:id]) ? true : false
      if tabs
        content_for(:script) { "Ext.onReady(function(){ Lipsiadmin.app.addBodyTabs(#{head}, '#{options[:tabs][:id]}')});\n" }
      else
        content_for(:script) { "Ext.onReady(function(){ Lipsiadmin.app.addBody(#{head})});\n" }
      end
      str = ""
      if head
        str += "<div id=\"contentHeader\">
        	<div id=\"content-header-left\">#{options[:text]}</div>
        	<div id=\"content-header-right\">#{image_submit_tag "backend/btn_save.png", :onclick => "$('adminForm').submit()"}</div>
        	<div style=\"clear:both\" />
        </div>"
      end

      str += "<div id=\"contentMain\">#{capture(&block)}</div>"

      concat str, block.binding
    end
    
    def tab(options={}, &block)
      content_for(:style) { "#contentMain { padding:0px; }" }
      content_for(:script) { "Ext.onReady(function(){ Lipsiadmin.app.addTab('#{options[:id]}', '#{options[:title]}', #{options[:show] ? true : false})});\n" }
      str = "<div id=\"#{options[:id]}\" class=\"x-hide-display\">#{capture(&block)}</div>"
      concat str, block.binding
    end
  end
end