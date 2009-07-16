module Lipsiadmin
  module Ext
    # Generate a new Ext.Toolbar
    # 
    #   Examples:
    # 
    #     var toolBar = new Ext.Toolbar([{
    #         handler: show,
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
    #     bar.add "Add",  :handler => "show".to_l, :icon => "...", :other => "..."
    #     bar.add "Edit", :handler => "Backend.app.loadHtml('/accounts/'+accounts_grid.getSelected().id+'/edit')".to_l, :other => "..."
    #   end
    #
    class ToolBar < Component

      def initialize(options={}, &block)#:nodoc:
        super("Ext.Toolbar", { :buttons => [] }.merge(options))
        yield self if block_given?
      end
      
      # Add new items to a Ext.Toolbar
      # 
      #   # Generates: { handler: show, text: "Add", other: "...", icon: "..." }
      #   add_button :text => "Add",  :handler => "show".to_l, :icon => "...", :other => "..."
      # 
      def add_button(options, &block)
        config[:buttons] << (options.is_a?(String) ? options : Button.new(options, &block).config)
      end
    end
  end
end