module LipsiaSoft
  module BetterTagHelper
    include ActionView::Helpers
    
    def password_field(object_name, method, options = {})
      options[:class] ||= "password_field"
      options.merge!(:onblur => "this.className=this.oldClassName", :onfocus => "this.oldClassName=this.className;this.className='password_field_sel'") 
      InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_input_field_tag("password", options)
    end
    
    def password_field_tag(name = "password", value = nil, options = {})
      options[:class] ||= "password_field"
      options.merge!(:onblur => "this.className=this.oldClassName", :onfocus => "this.oldClassName=this.className;this.className='password_field_sel'") 
      text_field_tag(name, value, options.update("type" => "password"))
    end
    
    def text_area(object_name, method, options = {})
      options[:class] ||= "text_area"
      options.merge!(:onblur => "this.className=this.oldClassName", :onfocus => "this.oldClassName=this.className;this.className='text_area_sel'") 
      InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_text_area_tag(options)
    end
    
    def text_area_tag(name, content = nil, options = {})
      options[:class] ||= "text_area"
      options.merge!(:onblur => "this.className=this.oldClassName", :onfocus => "this.oldClassName=this.className;this.className='text_area_sel'") 
      options.stringify_keys!

      if size = options.delete("size")
        options["cols"], options["rows"] = size.split("x")
      end

      content_tag :textarea, content, { "name" => name, "id" => name }.update(options.stringify_keys)
    end
    
    def text_field(object_name, method, options = {})
      options[:class] ||= "text_field" 
      if options[:onclick] == :clear_value
        options.delete(:onclick)
        options.merge!(:onblur => "if(this.value=='')this.value=this.defaultValue;this.className=this.oldClassName", 
                       :onfocus => "if(this.value==this.defaultValue)this.value='';this.oldClassName=this.className;this.className='text_field_sel'")
      else
        options.merge!(:onblur => "this.className=this.oldClassName", :onfocus => "this.oldClassName=this.className;this.className='text_field_sel'") 
      end
      InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_input_field_tag("text", options)
    end

    def text_field_tag(name, value = nil, options = {})
      options[:class] ||= "text_field" 
      if options[:onclick] == :clear_value
        options.delete(:onclick)
        options.merge!(:onblur => "if(this.value=='')this.value=this.defaultValue;this.className=this.oldClassName", 
                       :onfocus => "if(this.value==this.defaultValue)this.value='';this.oldClassName=this.className;this.className='text_field_sel'")
      else
        options.merge!(:onblur => "this.className=this.oldClassName", :onfocus => "this.oldClassName=this.className;this.className='text_field_sel'") 
      end
      tag :input, { "type" => "text", "name" => name, "id" => name, "value" => value }.update(options.stringify_keys)
    end
    
    def submit_tag(value = "Save changes", options = {})
      options[:class] ||= "submit_tag" 
      options.stringify_keys!

      if disable_with = options.delete("disable_with")
        options["onclick"] = "this.disabled=true;this.value='#{disable_with}';this.form.submit();#{options["onclick"]}"
      end

      tag :input, {"type" => "submit", "name" => "commit", "value" => value }.update(options.stringify_keys)
    end
  end
end