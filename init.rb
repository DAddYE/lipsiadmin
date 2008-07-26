require 'access_control'
require 'controllers_helpers'
require 'authenticated_system'
require 'better_errors'
require 'better_nested_set'
require 'better_tag_helper'
require 'better_error_messages_for'
require 'without_table'
require 'lipsiadmin_helper'
require 'serializo'
require 'lipsiadmin'
require 'paperclip'
require 'pdf_builder'
require 'prototype_helper'
require 'responds_to_parent'
require 'localization_simplified'
require 'haml'
require 'commands'

Haml.init_rails(binding)

ActiveRecord::Base.class_eval do
  include LipsiaSoft::Acts::NestedSet
  include LipsiaSoft::BetterErrors
end

ActionView::Base.class_eval do
  include LipsiaSoft::BetterTagHelper
  include LipsiaSoft::BetterErrorMessagesFor
end

ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods.class_eval do
  include LipsiaSoft::PrototypeHelper
end

ActionController::Base.class_eval do
  include LipsiaSoft::ControllersHelpers
  include LipsiaSoft::AuthenticatedSystem
  include LipsiaSoft::PdfBuilder
  include LipsiaSoft::RespondsToParent
end

ActiveRecord::Base.extend(Paperclip::ClassMethods)
File.send :include, Paperclip::Upfile

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_class = "fieldWithErrors"
  if html_tag =~ /<(input|textarea|select)[^>]+class=/
    class_attribute = html_tag =~ /class=['"]/
    html_tag.insert(class_attribute + 7, "#{error_class} ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " class='#{error_class}' "
  end
  html_tag
end

# Custom Haml Template Generator
Rails::Generator::Commands::Create.send :include, Lipsiadmin::Commands::Create