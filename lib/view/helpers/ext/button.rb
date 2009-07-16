module Lipsiadmin
  module Ext
    # Generate a new Ext.Button
    # 
    # This component is usefull for ex in toolbars
    # 
    #   # Generates:
    #   #{
    #   #  buttons: [{
    #   #    disabled: false,
    #   #    text: Backend.locale.buttons.add,
    #   #    id: "add",
    #   #    cls: "x-btn-text-icon add"
    #   #  },{
    #   #    disabled: true,
    #   #    text: Backend.locale.buttons.edit,
    #   #    id: "edit",
    #   #    cls: "x-btn-text-icon edit"
    #   #  },{
    #   #    disabled: true,
    #   #    text: Backend.locale.buttons.remove,
    #   #    id: "remove",
    #   #    cls: "x-btn-text-icon remove"
    #   #  },{
    #   #    disabled: false,
    #   #    menu: [{
    #   #    text: "Test Me"
    #   #  },{
    #   #    text: "IM a sub Menu"
    #   #  }],
    #   #    text: Backend.locale.buttons.print,
    #   #    id: "print",
    #   #    cls: "x-btn-text-icon print"
    #   #  }]
    #   #}
    #   tbar.add_button :text => "Backend.locale.buttons.add".to_l,    :id => "add",    :disabled => false,  :cls => "x-btn-text-icon add",    :handler => "add".to_l
    #   tbar.add_button :text => "Backend.locale.buttons.edit".to_l,   :id => "edit",   :disabled => true,   :cls => "x-btn-text-icon edit",   :handler => "edit".to_l
    #   tbar.add_button :text => "Backend.locale.buttons.remove".to_l, :id => "remove", :disabled => true,   :cls => "x-btn-text-icon remove", :handler => "remove".to_l
    #   tbar.add_button :text => "Backend.locale.buttons.print".to_l,  :id => "print",  :disabled => false,  :cls => "x-btn-text-icon print" do |menu|
    #     menu.add_button :text => "Test Me"
    #     menu.add_button :text => "IM a sub Menu"
    #   end    
    #
    class Button < Component

      def initialize(options={}, &block)#:nodoc:
        super("Ext.Button", options)
        yield self if block_given?
      end
      
      # Add new Button to the menu of this one
      # 
      #   # Generates: { handler: show, text: "Add", other: "...", icon: "..." }
      #   add_button :text => "Add",  :handler => "show".to_l, :icon => "...", :other => "..."
      # 
      def add_button(options, &block)
        config[:menu] ||= []
        config[:menu] << (options.is_a?(String) ? options : Button.new(options, &block).config)
      end
    end
  end
end