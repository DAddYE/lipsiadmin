module Lipsiadmin
  module Ext
    # Generate a full customizable Ext.GridPanel
    #
    # Examples:
    #
    #   # Returns:
    #   #   var grid = new Ext.grid.GridPanel({
    #   #     clicksToEdit: 1,
    #   #     border: false,
    #   #     bodyBorder: false,
    #   #     store: store,
    #   #     view: groupingView,
    #   #     region: "center",
    #   #     sm: new Ext.grid.CheckboxSelectionModel(),
    #   #     bbar: pagingToolbar,
    #   #     plugins: [new Ext.grid.Search()],
    #   #     viewConfig: { forceFit: true },
    #   #     id: "grid-posts",
    #   #     cm: columnModel,
    #   #     tbar: toolBar
    #   #   });
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
        super("Ext.grid.GridPanel", options)
        
        # Write default configuration if not specified
        config[:plugins]      ||= []
        viewConfig            l("{ forceFit: true }")       
        clicksToEdit          l(1)                          
        border                l(false)                      
        bodyBorder            l(false)                      
        region                "center"                      
        sm                    :checkbox                     
        add_plugin            l("new Ext.grid.Search()")    
        view                  :default                      
        on(:dblclick, :edit, l("this"))          
        
        yield self if block_given?
      end
      
      # Define the selection model of this grid.
      # You can pass: 
      #   
      # * :checkbox || :default
      # * :row
      # * custom (eg. Component.new("some"))
      # 
      # It generate some like:
      # 
      #   new Ext.grid.CheckboxSelectionModel()
      # 
      def sm(value)
        selmodel = case value
          when :default  then Component.new("Ext.grid.CheckboxSelectionModel")
          when :checkbox then Component.new("Ext.grid.CheckboxSelectionModel")
          when :row      then Component.new("Ext.grid.RowSelectionModel")
          when Component then value
        end
        before << selmodel.to_s
        config[:sm] = l(selmodel.get_var)
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
      def bbar(value=nil, &block)
        bbar = value.is_a?(Hash) ? Component.new("Ext.PagingToolbar", value) : value
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
      def view(value=nil, &block)
        if value.is_a?(Symbol) && (value == :default)
          view = Component.new("Ext.grid.GroupingView", { :forceFit => true })
        elsif value.is_a?(Hash)
          view = Component.new("Ext.grid.GroupingView", { :forceFit => true })
        else
          view = value
        end
        
        before << view.to_s
        after  << view.after
        config[:view] = l(view.get_var)
      end
      
      # Generate or set a new Ext.data.GroupingStore
      def store(value=nil, url=nil, &block)
        datastore = value.is_a?(Store) ? value : Store.new(&block)
        before << datastore.to_s
        after  << datastore.after
        config[:store] = l(datastore.get_var)
      end
      
      # Generate or set new Ext.grid.ColumnModel
      def columns(value=nil, &block)
        options = { :columns => [] }
        if config[:sm] && before.find { |js| js.start_with?("var #{config[:sm]} = new Ext.grid.CheckboxSelectionModel") }
          options[:columns] << config[:sm]
        end
        columnmodel = value.is_a?(ColumnModel) ? value : ColumnModel.new(options, &block)
        before << columnmodel.to_s
        after  << columnmodel.after
        config[:cm] = l(columnmodel.get_var)
      end
      
      # The base_path used for ToolBar, it's used for generate [:new, :edit, :destory] urls
      def base_path(value)
        @base_path = value
      end
      
      # The path for ToolBar New Button, if none given we use the base_path
      def new_path(value)
        @new_path = value
      end
      
      # The path for ToolBar Edit Button, if none given we use the base_path
      def edit_path(value)
        @edit_path = value
      end
      
      # The path for ToolBar Delete Button, if none given we use the base_path
      def destroy_path(value)
        @destroy_path = value
      end
      
      # The forgery_protection_token used for ToolBar
      def forgery_protection_token(value)
        @forgery_protection_token = value
      end
      
      # The authenticity_token used for ToolBar
      def authenticity_token(value)
        @authenticity_token = value
      end
      
      # Returns getSelectionModel().getSelected()
      # 
      #   Examples:
      # 
      #     # Generates: grid.getSelectionModel().getSelected().id
      #     grid.get_selected
      #     
      #     # Generates: getSelectionModel().getSelected().data['name']
      #     grid.get_selected(:name)
      # 
      def get_selected(data=:id)
        raise_error "No Column Selection Model Defined" if config[:sm].blank?
        if data.to_sym == :id
          l("#{config[:sm]}.getSelected().id")
        else
          l("#{config[:sm]}.getSelected().data[#{data.to_json}]")
        end
      end
      
      # Return the javascript for create a new Ext.grid.GridPanel
      def to_s
        if @default_tbar
          raise_error "You must provide the base_path for autobuild toolbar."                      if @base_path.blank? && @new_path.blank? && @edit_path.blank? && @destroy_path.blank?
          raise_error "You must provide the new_path for autobuild button new of toolbar."         if @base_path.blank? && @new_path.blank?
          raise_error "You must provide the edit_path for autobuild button edit of toolbar."       if @base_path.blank? && @edit_path.blank?
          raise_error "You must provide the destroy_path for autobuild button destroy of toolbar." if @base_path.blank? && @destroy_path.blank?
          raise_error "You must provide the forgery_protection_token for autobuild toolbar."       if @forgery_protection_token.blank?
          raise_error "You must provide the authenticity_token for autobuild toolbar."             if @authenticity_token.blank?
          raise_error "You must provide the grid for autobuild toolbar."                           if get_var.blank?
          raise_error "You must provide the selection model for autobuild toolbar."                if config[:sm].blank?
          raise_error "You must provide the store."                                                if config[:store].blank?
        end
        
        if @default_tbar
          after << render_javascript(:grid_functions, :var => get_var, :store => config[:store], :sm => config[:sm], :tbar => config[:tbar])
        end
        
        if config[:store]
          after << "#{config[:store]}.on('beforeload', function(){ Backend.app.mask(); });"
          after << "#{config[:store]}.on('load', function(){ Backend.app.unmask(); });"
          after << "#{config[:store]}.load();"
        end
        
        after << "Backend.app.addItem(#{get_var})"
        "#{before_js}var #{get_var} = new Ext.grid.GridPanel(#{config.to_s});#{after_js}"
      end
    end
  end
end