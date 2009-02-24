module Lipsiadmin
  module View
    module Helpers
      module TagHelper
        include ActionView::Helpers::FormHelper
        include ActionView::Helpers::FormTagHelper
    
        def text_area_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-field"
          options[:style] ||= "width:100%;height:80px"
          text_area_without_style(name, value, options)
        end
        alias_method_chain :text_area, :style
    
        def text_area_tag_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-field"
          options[:style] ||= "width:100%;height:80px"
          text_area_tag_without_style(name, value, options)
        end
        alias_method_chain :text_area_tag, :style
    
        def text_field_with_style(name, method, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          text_field_without_style(name, method, options)
        end
        alias_method_chain :text_field, :style

        def text_field_tag_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          text_field_tag_without_style(name, value, options)
        end
        alias_method_chain :text_field_tag, :style

        def password_field_with_style(name, method, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          password_field_without_style(name, method, options)
        end
        alias_method_chain :password_field, :style

        def password_field_tag_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          password_field_tag_without_style(name, value, options)
        end
        alias_method_chain :password_field_tag, :style
      end
    end
  end
end