module Lipsiadmin#:nodoc:
  module Ext#:nodoc:
    # Generate a new Ext.data.GroupingStore
    # 
    # Examples:
    # 
    #   var store = new Ext.data.GroupingStore({
    #     reader: new Ext.data.JsonReader({
    #       id:'id', 
    #       totalProperty:'count', root:'results',
    #       fields:[{
    #       name: "accounts.name"
    #     },{
    #       name: "accounts.categories.name"
    #     },{
    #       type: "date",
    #       renderer: Ext.util.Format.dateRenderer(),
    #       name: "accounts.date",
    #       dateFormat: "c"
    #     },{
    #       type: "date",
    #       renderer: Ext.util.Format.dateTimeRenderer(),
    #       name: "accounts.datetime",
    #       dateFormat: "c"
    #     } ]}),
    #     proxy: new Ext.data.HttpProxy({ url:'/backend/accounts.json' }),
    #     remoteSort: true
    #   });
    # 
    #   grid.store do |store|
    #     store.url "/backend/accounts.json"
    #     store.add "accounts.name"
    #     store.add "accounts.categories.name"
    #     store.add "accounts.date", :type => :date
    #     store.add "accounts.datetime", :type => :datetime
    #   end
    #
    class Store < Component
      attr_accessor :items
      
      def initialize(options={}, &block)#:nodoc:
        @items   = []
        super("Ext.data.GroupingStore", options)
        remoteSort true                     if config[:remoteSort].blank?
        baseParams("_method" => "GET")      if config[:baseParams].blank?
        yield self if block_given?
      end
      
      # The url for getting the json data
      def url(value)
        @url = value
      end
      
      # This add automatically fields from an array
      def fields(fields)
        fields.each { |options| add(nil, options) }
      end

      # Add fields to a Ext.data.JsonReader 
      # 
      # Examples:
      # 
      #   {
      #     type: "date",
      #     renderer: Ext.util.Format.dateTimeRenderer(),
      #     name: "accounts.datetime",
      #     dateFormat: "c"
      #   }
      # 
      #   add "accounts.datetime", :type => :datetime
      #
      def add(name=nil, options={})#:nodoc:
        options[:name] = name if name
        case options[:type]
          when :date     then options.merge!({ :type => "date", :dateFormat => "Y-m-d" })
          when :datetime then options.merge!({ :type => "date", :dateFormat => "c" })
        end
        raise ComponentError, "You must provide a Name for all fields" if options[:name].blank?
        @items << Configuration.new(options)
      end
      
      # Return the javascript for create a new Ext.data.GroupingStore 
      def to_s
        raise ComponentError, "You must provide the correct var the store."       if get_var.blank?
        raise ComponentError, "You must provide the url for get the store data."  if @url.blank? && config[:proxy].blank?
        raise ComponentError, "You must provide some fields for get build store." if items.blank?
        config[:proxy]  = default_proxy  if config[:proxy].blank?
        config[:reader] = default_reader if config[:reader].blank?
        super
      end
      
      private
        def default_proxy
          l("new Ext.data.HttpProxy(#{Configuration.new(:url => @url).to_s(2)})")
        end

        def default_reader
          options = { :id => "id", :totalProperty => "count", :root => "results", :fields => l("["+items.collect { |i| i.to_s(3) }.join(",")+"]")  }
          l("new Ext.data.JsonReader(#{Configuration.new(options).to_s(2)})")
        end

    end
  end
end