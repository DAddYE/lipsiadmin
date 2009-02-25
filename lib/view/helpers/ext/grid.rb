module Lipsiadmin
  module Ext
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
    class Grid < Component
      def initialize(options={}, &block)#:nodoc:
        # Call Super Class for initialize configuration
        super(options, &block)
        # Write default configuration if not specified
        config[:plugins]      ||= []
        viewConfig            l("{ forceFit: true }")       if  config[:viewConfig].blank?
        clicksToEdit          l(1)                          if  config[:clicksToEdit].blank?
        border                l(false)                      if  config[:border].blank?
        bodyBorder            l(false)                      if  config[:bodyBorder].blank?
        region                "center"                      if  config[:region].blank?
        sm                    :checkbox                     if  config[:sm].blank?
        add_plugin            l("new Ext.grid.Search()")    if !config[:tbar].blank?
        view                  :default                      if  config[:view].blank?
      end
      
      # Define the selection model of this grid.
      # You can pass: 
      #   
      # * :checkbox
      # * :default (alias for checkbox)
      # * :row
      # 
      # It generate some like:
      # 
      #   new Ext.grid.CheckboxSelectionModel()
      # 
      def sm(value)
        case value
        when :checkbox || :default
          config[:sm] = l("new Ext.grid.CheckboxSelectionModel()")
        when :row
          config[:sm] = l("new Ext.grid.RowSelectionModel()")
        else
          config[:sm] = value
        end
      end
      
      # Define the title of the grid
      def title(title)
        before << "Backend.app.setTitle(#{title.to_json});"
      end
      
      # Assign plugins for the current grid
      def plugins(plugins)
        config[:plugins] = plugins
      end
      
      # Add a single plugin to the grid plugins
      def add_plugin(plugins)
        config[:plugins] << plugins
      end
          
      # Generate or set a new Ext.Toolbar
      # You can pass tbar :default options that will create 
      # defaults buttons for add, edit and remove records, it's generate also
      # the javascript for manage them.
      # for use this you need to set for the grid the: +base_path+, +forgery_protection_token+,
      # +authenticity_token+ and +store+.
      #
      #   Examples:
      #     var toolBar = new Ext.Toolbar([{
      #         handler: add,
      #         disabled: false,
      #         text: Backend.locale.buttons.add,
      #         cls: "x-btn-text-icon add",
      #         id: "add"
      #      },{
      #         handler: edit,
      #         disabled: true,
      #         text: Backend.locale.buttons.edit,
      #         cls: "x-btn-text-icon edit",
      #         id: "edit"
      #      },{
      #         handler: remove,
      #         disabled: true,
      #         text: Backend.locale.buttons.remove,
      #         cls: "x-btn-text-icon remove",
      #         id: "remove"
      #     }]);
      #
      #   tbar  :default
      # 
      def tbar(obj=nil, &block)
        tbar = obj.is_a?(ToolBar) ? obj : ToolBar.new
        if obj == :default
          tbar.add l("Backend.locale.buttons.add"),    :id => "add",    :disabled => literal(false), :cls => "x-btn-text-icon add",    :handler => l("add")
          tbar.add l("Backend.locale.buttons.edit"),   :id => "edit",   :disabled => literal(true),  :cls => "x-btn-text-icon edit",   :handler => l("edit")
          tbar.add l("Backend.locale.buttons.remove"), :id => "remove", :disabled => literal(true),  :cls => "x-btn-text-icon remove", :handler => l("remove")
          @default_tbar = true 
        end
        yield tbar if block_given?
        before << tbar.to_s
        after  << tbar.after
        config[:tbar] = l(tbar.get_var)
      end
      
      # Generate or set a new Ext.Toolbar
      # 
      #   Examples:
      #     bbar: new Ext.PagingToolbar({
      #       pageSize: <%= params[:limit] %>,
      #       store: js,
      #       displayInfo: true
      #     })
      #   bbar :pageSize => params[:limit], :store => store.get_var, displayInfo: true
      # 
      def bbar(obj=nil, &block)
        bbar = obj.is_a?(Hash) ? PagingToolbar.new(obj) : obj
        before << bbar.to_s
        after  << bbar.after
        config[:bbar] = l(bbar.get_var)
      end

      # Generate or set a new Ext.grid.GroupingView
      # You can pass tbar :default options that will autocreate a correct GroupingView
      # 
      #   Examples:
      #     view: new Ext.grid.GroupingView({
      #       forceFit:true,
      #       groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Foo" : "Bar"]})'
      #     })
      #   view :forceFit => true, :groupTextTpl => "{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Foo" : "Bar"]})"
      # 
      def view(obj=nil, &block)
        if obj.is_a?(Symbol) && (obj == :default)
          view = GroupingView.new({ :forceFit => true })
        elsif obj.is_a?(Hash)
          view = GroupingView.new(obj)
        else
          view = obj
        end
        
        before << view.to_s
        after  << view.after
        config[:view] = l(view.get_var)
      end
      
      # Generate or set a new Ext.data.GroupingStore
      def store(obj=nil, url=nil, &block)
        datastore = obj.is_a?(Store) ? obj : Store.new(&block)
        before << datastore.to_s
        after  << datastore.after
        config[:store] = l(datastore.get_var)
      end
      
      # Generate or set new Ext.grid.ColumnModel
      def columns(obj=nil, &block)
        columnmodel = obj.is_a?(ColumnModel) ? obj : ColumnModel.new(&block)
        before << columnmodel.to_s
        after  << columnmodel.after
        config[:colModel] = l(columnmodel.get_var)
      end
      
      # The base_path used for ToolBar, it's used for generate [:new, :edit, :destory] urls
      def base_path(value)
        @base_path = value
      end
      
      # The forgery_protection_token used for ToolBar
      def forgery_protection_token(value)
        @forgery_protection_token = value
      end
      
      # The authenticity_token used for ToolBar
      def authenticity_token(value)
        @authenticity_token = value
      end
      
      # Return the javascript for create a new Ext.grid.GridPanel
      def to_s
        raise ComponentError, "You must provide the base_path for autobuild toolbar."                if @default_tbar && @base_path.blank?
        raise ComponentError, "You must provide the forgery_protection_token for autobuild toolbar." if @default_tbar && @forgery_protection_token.blank?
        raise ComponentError, "You must provide the authenticity_token for autobuild toolbar."       if @default_tbar && @authenticity_token.blank?
        raise ComponentError, "You must provide the grid for autobuild toolbar."                     if @default_tbar && get_var.blank?
        raise ComponentError, "You must provide the store."                                          if @default_tbar && config[:store].blank?
        if @default_tbar
          after << render_javascript("grid", :var => get_var, :store => config[:store])
        end
        if config[:store]
          after << "#{config[:store]}.on('beforeload', function(){ Backend.app.mask(); });"
          after << "#{config[:store]}.on('load', function(){ Backend.app.unmask(); });"
          after << "#{config[:store]}.load();"
        end
        after << "Backend.app.addItem(#{get_var})"
        "#{before_js}var #{get_var} = new Ext.grid.GridPanel(#{config.to_s});#{after_js}"
      end
      alias_method :to_js, :to_s
    end
  end
end