require "date"
require 'action_view/helpers/tag_helper'
module ActionView
  module Helpers#:nodoc:
    module DateHelper#:nodoc:
      def ext_date_select(object_name, method, options = {}, html_options = {})
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_ext_date_select_tag(options, html_options)
      end
      
      def ext_datetime_select(object_name, method, options = {}, html_options = {})
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_ext_datetime_select_tag(options, html_options)
      end
    end


    class InstanceTag #:nodoc:
      def to_ext_date_select_tag(options = {}, html_options = {})
        to_datetime_select_tag({ :hideTime => true.to_l }.merge(options), html_options)
      end

      def to_ext_datetime_select_tag(options = {}, html_options = {})
        html_options = html_options.stringify_keys
        html_options = DEFAULT_FIELD_OPTIONS.merge(html_options)
        html_options["type"] = "hidden"
        html_options["value"] ||= value_before_type_cast(object)
        html_options["value"] &&= html_escape(html_options["value"])
        add_default_name_and_id(html_options)
        options = { :applyTo => html_options["id"], :dateFormat => I18n.t("extjs.dateFormat") }.merge(options)
        tag("input", html_options) +
        content_tag(:script, "new Ext.form.DateTimeField(#{options.to_json});", :type => Mime::JS)
      end
    end

    class FormBuilder#:nodoc:
      def ext_date_select(method, options = {}, html_options = {})
        @template.ext_date_select(@object_name, method, options.merge(:object => @object), html_options)
      end

      def ext_datetime_select(method, options = {}, html_options = {})
        @template.ext_datetime_select(@object_name, method, options.merge(:object => @object), html_options)
      end
    end
  end
end