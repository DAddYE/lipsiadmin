module LipsiaSoft
  module LipsiadminHelper
    def tab(name, options={}, &block)
      options[:id] ||= name.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/-+$/, '').gsub(/^-+$/, '')
      concat content_tag(:div, capture(&block), { :id => options[:id], :class => "x-hide-display" })
      @tabs = [] unless @tabs
      @tabs << content_tag(:script, "Ext.onReady(function(){ Lipsiadmin.app.addTab('#{options[:id]}', '#{escape_javascript name}', #{@tabs.blank? ? true : false})});", :type => Mime::JS)
    end

    def form_page(url_for_options = {}, options = {}, *parameters_for_url, &block)
      options[:target] ||= 'ajax-frame'
      options[:id] ||= 'admin-form'
      head = options[:title] ? true : false 
 
      concat content_tag(:script, "Ext.onReady(function(){ styledForms() })", :type => Mime::JS)
      
      if head
        concat tag(:div, {:id => "content-header"}, true)
        concat content_tag(:div, options.delete(:title), :id => "content-header-left")
        if !options[:hide_save] || options[:hide_save] != true
          concat content_tag(:div, image_submit_tag("backend/btn_save.png", :onclick => "Lipsiadmin.app.submitForm()"), :id => "content-header-right")
        end
        concat content_tag(:div, "", :class => "clear")
        concat "</div>"
      end

      html_options = html_options_for_form(url_for_options, options, *parameters_for_url)

      concat tag(:div, { :id => "content-main"}, true)
      concat form_tag_html(html_options)
      concat content_tag(:div, capture(&block), :id => 'form-fields')
      concat "</form>"
      concat "</div>"

      if @tabs
        concat content_tag(:script, "Ext.onReady(function(){ Lipsiadmin.app.addBodyTabs(#{head}, 'form-fields') })", :type => Mime::JS)
        @tabs.each { |t| concat t }
      else
        concat content_tag(:script, "Ext.onReady(function(){ Lipsiadmin.app.addBody(#{head}) })", :type => Mime::JS)
      end
    end
  end
end