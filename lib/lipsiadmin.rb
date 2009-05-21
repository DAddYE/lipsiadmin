require 'utils/html_entities'
require 'utils/literal'
require 'utils/pdf_builder'
require 'access_control/authentication'
require 'access_control/base'
require 'mailer/pdf_builder'
require 'mailer/exception_notifier'
require 'view/helpers/active_record_helper'
require 'view/helpers/backend_helper'
require 'view/helpers/frontend_helper'
require 'view/helpers/view_helper'
require 'view/helpers/ext_helper'
require 'controller/ext'
require 'controller/pdf_builder'
require 'controller/responds_to_parent'
require 'controller/lipsiadmin_controller'
require 'controller/ext'
require 'controller/rescue'
require 'data_base/without_table'
require 'data_base/translate_attributes'
require 'data_base/attachment'
require 'data_base/attachment_table'
require 'data_base/utility_scopes'
require 'haml'
require 'version'
require 'generator'

Haml.init_rails(binding)
Haml::Template.options[:attr_wrapper] = "\""

# Global Extension

ActiveRecord::Base.class_eval do
  include Lipsiadmin::DataBase::TranslateAttributes
  include Lipsiadmin::DataBase::Attachment
  include Lipsiadmin::DataBase::UtilityScopes
end

ActionView::Base.class_eval do
  include Lipsiadmin::View::Helpers::FormHelper
  include Lipsiadmin::View::Helpers::FormTagHelper
  include Lipsiadmin::View::Helpers::DateHelper
  include Lipsiadmin::View::Helpers::CountrySelectHelper
end

ActionView::Helpers::FormBuilder.send(:include, Lipsiadmin::View::Helpers::FormBuilder)

ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods.class_eval do
  include Lipsiadmin::View::Helpers::ExtHelper
end

ActionController::Base.class_eval do
  include Lipsiadmin::Controller::Rescue
  include Lipsiadmin::Controller::PdfBuilder
  include Lipsiadmin::Controller::RespondsToParent
  include Lipsiadmin::Controller::Ext
  include Lipsiadmin::AccessControl::Authentication
end

# For Attachments
File.send(:include, Lipsiadmin::Attachment::Upfile)

# For javascript objects
Object.send(:include, Lipsiadmin::Utils::Literal)

# Custom CSS and JS
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :backend => ["ext", "standard", "backend"], :backend_slate => ["ext", "ext-slate", "standard", "backend-slate"]
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :backend => ["ext", "locale", "backend"]

# Add a better organization of locales
I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', 'backend',  '*.{rb,yml}')]
I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', 'frontend', '*.{rb,yml}')]
I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', 'models',   '*.{rb,yml}')]
I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', 'models',   '**/*.{rb,yml}')]
I18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', 'rails',    '*.{rb,yml}')]

# Load generator languages
I18n.load_path << File.dirname(__FILE__) + '/locale/it.yml'
I18n.load_path << File.dirname(__FILE__) + '/locale/en.yml'
