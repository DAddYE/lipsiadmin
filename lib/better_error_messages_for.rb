module LipsiaSoft
  module BetterErrorMessagesFor
    include ActionView::Helpers
    
    def error_messages_for(*params)
      options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
      count   = objects.inject(0) {|sum, object| sum + object.errors.count }
      unless count.zero?
        html = {}
        [:id, :class].each do |key|
          if options.include?(key)
            value = options[key]
            html[key] = value unless value.blank?
          else
            html[key] = 'errorExplanation'
          end
        end
        error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
        content_tag(:div, 
            content_tag(:p, 'Ci sono dei problemi:') <<
            content_tag(:ul, error_messages) << 
            content_tag(:p, '&nbsp;'),
          html
        )
      else
        ''
      end
    end
    
    def ext_error_messages_for(*params)
      options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
      count   = objects.inject(0) {|sum, object| sum + object.errors.count }
      unless count.zero?
        html = {}
        [:id, :class].each do |key|
          if options.include?(key)
            value = options[key]
            html[key] = value unless value.blank?
          else
            html[key] = 'errorExplanation'
          end
        end
        header_message = "Attention"
        error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
        body_message   = content_tag(:ul, error_messages)
        javascript_tag("Ext.onReady(function(){ 
            Ext.Msg.show({
               title:'#{header_message}',
               msg: '#{escape_javascript(body_message)}',
               buttons: Ext.Msg.OK,
               minWidth: 400
            });
          });"
        )
      else
        ''
      end
    end
    
  end
end