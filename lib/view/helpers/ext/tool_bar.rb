module Lipsiadmin
  module Ext
    # Generate a new Ext.Toolbar
    # 
    #   Examples:
    # 
    #     var toolBar = new Ext.Toolbar([{
    #         handler: show();,
    #         text: "Add",
    #         other: "...",
    #         icon: "..."
    #       },{
    #         handler: Backend.app.loadHtml('/accounts/'+accounts_grid.getSelected().id+'/edit'),
    #         text: "Edit",
    #         other: "..."
    #     }]);
    #
    #   grid.tbar do |bar|
    #     bar.add "Add",  :handler => bar.l("show();"), :icon => "...", :other => "..."
    #     bar.add "Edit", :handler => bar.l("Backend.app.loadHtml('/accounts/'+accounts_grid.getSelected().id+'/edit')"), :other => "..."
    #   end
    #
    class ToolBar < Component
      attr_accessor :items
      def initialize(options={}, &block)#:nodoc:
        super("Ext.Toolbar", { :items => [] }.merge(options))
        yield self if block_given?
      end
      
      # Add new items to a Ext.Toolbar
      # 
      #   # Generates: { handler: show();, text: "Add", other: "...", icon: "..." }
      #   add "Add",  :handler => bar.l("show();"), :icon => "...", :other => "..."
      # 
      def add(name, options={})
        options[:text] = name
        config[:items] << Configuration.new(options)
      end
    end
  end
end