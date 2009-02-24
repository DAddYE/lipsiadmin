module Lipsiadmin
  module Ext
    # Generate a new Ext.grid.ColumnModel
    #
    #   Examples:
    # 
    #     var columnModel = new Ext.grid.ColumnModel([{
    #         header: "Name",
    #         dataIndex: "name"
    #       },{
    #         header: "Category",
    #         dataIndex: "category_name",
    #         query: "categories.name LIKE {query}"
    #       },{
    #         header: "Date",
    #         dataIndex: "date"
    #       },{
    #         header: "Created At",
    #         dataIndex: "created_at"
    #     }]);
    #     
    #   ColumnModel.new do |columns|
    #     columns.add :name,             "Name"
    #     columns.add :category_name,    "Category",      :query => "categories.name"
    #     columns.add :date,             "Date"
    #     columns.add :created_at,       "Created At"
    #   end
    #     
    class ColumnModel < Component
      attr_accessor :items
      
      def initialize(options={}, &block)#:nodoc:
        super({ :items => [] }.merge(options), &block)
      end
      
      # This add automatically fields from an array
      def fields(fields)
        fields.each { |options| add(nil, nil, options)  }
      end
      
      # Add columns to a Ext.grid.ColumnModel
      #
      #   # Generates: { header: "Created At", dataIndex: "accounts.datetime", sortable => true }
      #   add "Created At", "accounts.datetime", :sortable => l(true)
      #   
      def add(name=nil, data=nil, options={})
        options[:header] = name if name
        options[:dataIndex] = data if data
        case options[:renderer]
          when :date     then options.merge!(:renderer => l("Ext.util.Format.dateRenderer()"))
          when :datetime then options.merge!(:renderer => l("Ext.util.Format.dateTimeRenderer()"))
        end
        raise ComponentError, "You must provide header and dataIndex for generate a column model" if options[:header].blank? || options[:dataIndex].blank?
        config[:items] << Configuration.new(options)
      end
      
      # Return the javascript for create a new Ext.grid.ColumnModel
      def to_s
        "var #{get_var} = new Ext.grid.ColumnModel([#{config[:items].join(",")}]);"
      end
    end
  end
end