module Lipsiadmin
  module Ext
    # Generate a new Ext.PagingToolbar
    # 
    #   Examples:
    # 
    #     bbar: new Ext.PagingToolbar({
    #       pageSize: 50,
    #       store: ds,
    #       displayInfo: true
    #     })
    # 
    # 
    #
    class PagingToolbar < Component
      attr_accessor :items
      def initialize(options={}, &block)#:nodoc:
        super(options, &block)
        displayInfo true        if config[:displayInfo].blank?
      end
      
      # Return the javascript for create a new Ext.PagingToolbar
      def to_s
        raise ComponentError, "You must provide a store var for build a correct pagination." if config[:store].blank?
        "var #{get_var} = new Ext.PagingToolbar(#{config.to_s});"
      end
    end
  end
end