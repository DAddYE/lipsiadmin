module Lipsiadmin
  module Ext
    # Generate a new Ext.PagingToolbar
    # 
    #   Examples:
    # 
    #     new Ext.grid.GroupingView({
    #       forceFit:true,
    #       groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Foo" : "Bar"]})'
    #     })
    #
    class GroupingView < Component
      attr_accessor :items
      def initialize(options={}, &block)#:nodoc:
        super(options, &block)
        forceFit true        if config[:forceFit].blank?
      end
      
      # Return the javascript for create a new Ext.PagingToolbar
      def to_s
        "var #{get_var} = new Ext.grid.GroupingView(#{config.to_s});"
      end
    end
  end
end