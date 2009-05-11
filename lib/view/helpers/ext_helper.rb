require 'view/helpers/ext/component'
require 'view/helpers/ext/grid'
require 'view/helpers/ext/column_model'
require 'view/helpers/ext/tool_bar'
require 'view/helpers/ext/configuration'
require 'view/helpers/ext/store'

module Lipsiadmin
  module View
    module Helpers
      # Module containing the methods useful for ext/prototype
      module ExtHelper
      
        def self.included(base)#:nodoc:
          base.class_eval do
            alias_method_chain :to_s, :refactoring
          end
        end
      
        def to_s_with_refactoring #:nodoc:
          returning javascript = @lines * $/ do
            source = javascript.dup
          end
        end
      
        # Hide all open dialogs
        def hide_dialogs
          record "Ext.Msg.getDialog().hide()"
        end
      
        # Replaces the inner HTML of the Main Panel of +Backend+.
        #
        # +options_for_render+ may be either a string of HTML to insert, or a hash
        # of options to be passed to ActionView::Base#render.  For example:
        #
        #   # Replaces the inner HTML of the Main Panel of +Backend+.
        #   # Generates:  Backend.app.update("-- Contents of 'person' partial --");
        #   page.update :partial => 'person', :object => @person
        #      
        def update(*options_for_render)
          call "Backend.app.update", render(*options_for_render), true
        end
      
        # Load html/js and eval it's code
        # 
        #   # Generates: Backend.app.loadJs('/my/javascript.js');
        #   load(:controller => :my, :action => :javascript, :format => :js)
        #
        def load(location, cache = false)
          url = location.is_a?(String) ? location : @context.url_for(location)
          call "Backend.app.load", url, cache
        end
      
        # Show errors (if they are) for the given +objects+ and show a Ext.Message 
        # with explanation of the errors or if errors are empty, a congratulation message.
        # 
        #   # Generates: 
        #   #   Ext.Msg.show({
        #   #     title:Backend.locale.messages.alert.title,
        #   #     msg: '<ul>Name can't be blank!</ul>',
        #   #     buttons: Ext.Msg.OK,
        #   #     minWidth: 400
        #   #   })
        #   show_errors_for(@account)
        #
        def show_errors_for(*objects)
          count   = objects.inject(0) {|sum, object| sum + object.errors.count }
          unless count.zero?
            error_messages = objects.map {|object| object.errors.full_messages.map {|msg| "<li>#{msg}</li>" } }
            record "Ext.Msg.show({
                      title:    Backend.locale.messages.alert.title,
                      msg:      '<ul>#{escape_javascript(error_messages.join)}</ul>',
                      buttons:  Ext.Msg.OK,
                      minWidth: 400
                    });"
          else
            record "Ext.Msg.alert(Backend.locale.messages.compliments.title, Backend.locale.messages.compliments.message);"
          end
        end

        # Show a Ext.alert popup
        # 
        #   # Generates: Ext.Msg.alert('Hey!', 'Hello World')
        #   ext_alert('Hey!', 'Hello World')
        #
        def ext_alert(title, message)
          call "Ext.Msg.alert", title, message
        end

        # Unmask the Backend App
        # 
        #   # Generates: Backend.app.unmask()
        #   unmask
        #
        def unmask
          call "Backend.app.unmask"
        end
        
        # Mask the Backend App
        # 
        #   # Generates: Backend.app.mask('Hello World')
        #   mask("Hello World")
        #
        def mask(title=nil)
          call "Backend.app.mask", title
        end        
      
        # Create a javascript function
        # 
        #   # Generates: function() { window.show(); };
        #   page.fn("window.show();")
        #   or
        #   page.fn { |p| p.call "window.show" }
        #
        def fn(function=nil, &block)
          if function
            record "function() { #{literal(function)} }"
          else
            record block_to_function(function || block)
          end
        end
      
        # Generate a full customizable Ext.GridPanel
        #
        # Examples:
        #
        #   page.grid do |grid|
        #     grid.id "grid-posts"
        #     grid.title "List all Post"
        #     grid.base_path "/backend/posts"
        #     grid.forgery_protection_token request_forgery_protection_token
        #     grid.authenticity_token form_authenticity_token
        #     grid.tbar  :default
        #     grid.store do |store|
        #       store.url "/backend/posts.json"
        #       store.fields @column_store.store_fields
        #     end
        #     grid.columns do |columns|
        #       columns.fields @column_store.column_fields
        #     end
        #     grid.bbar  :store => grid.get_store, :pageSize => params[:limit]
        #   end
        # 
        def grid(options={}, &block)
          self << Lipsiadmin::Ext::Grid.new(options, &block)
        end
      end
    end
  end
end