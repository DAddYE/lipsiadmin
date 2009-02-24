require 'view/helpers/ext/component'
require 'view/helpers/ext/grid'
require 'view/helpers/ext/column_model'
require 'view/helpers/ext/tool_bar'
require 'view/helpers/ext/configuration'
require 'view/helpers/ext/store'
require 'view/helpers/ext/paging_toolbar'
require 'view/helpers/ext/grouping_view'

module Lipsiadmin
  module View
    module Helpers
      # Module containing the methods useful for ext/prototype
      module ExtHelper
      
        def self.included(base)
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
          call title, message
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
      
        # Generate a full customizable Ext.Grid
        #
        # Examples:
        #
        #   page.grid do |grid|
        #
        #     #Some standard config
        #     grid.title "List of all Account"
        #     grid.selection :checkbox
        #
        #     # TopBar & Buttons
        #     grid.ttbar do |bar|
        #       bar.add "Add",  :handler => grid.l("Backend.app.loadHtml('/backend/accounts/new')"), :icon => "...", :other => "..."
        #       bar.add "Edit", :handler => grid.l("Backend.app.loadHtml('/backend/accounts/'+accounts_grid.getSelected().id+'/edit')"), :other => "..."
        #       bar.add "Print" do |submenu|
        #         submenu.add "Print Invoice", :foo => "..."
        #         submenu.add "Print Account", :bar => "..."
        #       end
        #     end
        #
        #     or simply:
        #
        #     grid.ttbar :default do |ttbar|
        #       ttbar.path "/backend/accounts"
        #       ttbar.forgery_protection_token request_forgery_protection_token
        #       ttbar.authenticity_token form_authenticity_token
        #     end      
        #   
        #     # Columns
        #     grid.columns do |col|
        #       col.add "Name",          "accounts.name",          :searchable => false,  :sortable => true
        #       col.add "Category Name", "accounts.category.name", :sortable => :false
        #       col.add "Created At",    "accounts.created_at",    :type => "date", :format => "c", :renderer => Ext.call("Ext.Util.DateRenderer", "m/d/y")
        #     end
        #   
        #     # alternative you can simply do 
        #     # 
        #     # grid.columns :defaults, Account 
        #     # and they add all columns of Account Model.
        #     # 
        #     # or
        #     #
        #     # grid.coumns :default do |col|
        #     #   col.add "Projects",      "accounts.projects.collect(&:name).join(", ")", :searchable => false,  :sortable => true  
        #     #   col.add "Category Name", "accounts.category.name", :sortable => :false
        #     #   ...
        #     # end
        #     # In this way add other than accounts columns "Projects" and "Category Name"!    
        #   
        #     # Extra Examples
        #     # 
        #     # Render:
        #     # 
        #     # grid.on('dblclick', function(){
        #     #   Ext.Msg.alert('Title', 'Content');
        #     # });
        #     #
        #
        #     grid.on "dblclick" do
        #       Ext.call("Ext.Msg.alert", "Title", "Content")
        #     end
        #   
        #     grid.on "dblclick" do 
        #       Ext.call "Ext.Msg.alert", "Selected the row", "with name: #{Ext.grid.selected.name}"
        #     end
        #   
        #     grid.columns.first.on("dblclick") do
        #       Ext.call("Ext.Msg.alert", "Some", "One")
        #     end
        #   
        #     button = grid.buttons.get_by(:title, "Add")
        #     button = grid.buttons.get_by(:id, "add")
        #     col    = grid.columns.get_by(:id, "category_name")
        #   
        #     button.on("dblclick", Ext.fn("Ext.Msg.alert", "Hello World"))
        #   
        #     grid.append "/backend/accounts/grid_fn.js" # or :controller => :accounts, :action => :grid_fn, :format => :js
        #   end
        #
        def grid(&block)
          self << Lipsiadmin::Ext::Grid.new(&block)
        end
      end
    end
  end
end