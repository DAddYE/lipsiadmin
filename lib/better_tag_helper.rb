module LipsiaSoft
  module BetterTagHelper
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormTagHelper
    
    def text_area_with_style(name, value = nil, options = {})
      options[:class] ||= "text-area"
      text_area_without_style(name, value, options)
    end
    alias_method_chain :text_area, :style
    
    def text_area_tag_with_style(name, value = nil, options = {})
      options[:class] ||= "text-area"
      text_area_tag_without_style(name, value, options)
    end
    alias_method_chain :text_area_tag, :style
    
    def text_field_with_style(name, method, options = {})
      options[:class] ||= "text-input"
      text_field_without_style(name, method, options)
    end
    alias_method_chain :text_field, :style

    def text_field_tag_with_style(name, value = nil, options = {})
      options[:class] ||= "text-input"
      text_field_tag_without_style(name, value, options)
    end
    alias_method_chain :text_field_tag, :style

    def password_field_with_style(name, method, options = {})
      options[:class] ||= "text-input"
      password_field_without_style(name, method, options)
    end
    alias_method_chain :password_field, :style

    def password_field_tag_with_style(name, value = nil, options = {})
      options[:class] ||= "text-input"
      password_field_tag_without_style(name, value, options)
    end
    alias_method_chain :password_field_tag, :style

  end
end