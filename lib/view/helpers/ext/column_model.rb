module Lipsiadmin
  module Ext
    # Generate a new Ext.grid.ColumnModel
    #
    #   Examples:
    # 
    #     var columnModel = new Ext.grid.ColumnModel({
    #       columns: [{
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
    #     }]});
    #     
    #   ColumnModel.new do |columns|
    #     columns.add :name,             "Name"
    #     columns.add :category_name,    "Category",      :dataIndex => "categories.name"
    #     columns.add :date,             "Date"
    #     columns.add :created_at,       "Created At"
    #   end
    #     
    class ColumnModel < Component      
      def initialize(options={}, &block)#:nodoc:
        super("Ext.grid.ColumnModel", { :columns => [] }.merge(options))
        yield self if block_given?
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
      # You can pass :renderer
      #   
      #   # Generates: Ext.util.Format.dateRenderer()
      #   :renderer => :date
      #   # Generates: Ext.util.Format.dateTimeRenderer()
      #   :renderer => :datetime
      #   # Generates: Ext.util.Format.eurMoney
      #   :renderer => :eur_money
      #   # Generates: Ext.util.Format.usMoney
      #   :renderer => :us_money
      #   # Generates: Ext.util.Format.boolRenderer
      #   :renderer => :boolean
      # 
      def add(name=nil, data=nil, options={})
        options[:header] = name if name
        options[:dataIndex] = data if data
        case options[:renderer]
          when :date        then options.merge!(:renderer => l("Ext.util.Format.dateRenderer()"))
          when :datetime    then options.merge!(:renderer => l("Ext.util.Format.dateTimeRenderer()"))
          when :eur_money   then options.merge!(:renderer => l("Ext.util.Format.eurMoney"))
          when :us_money    then options.merge!(:renderer => l("Ext.util.Format.usMoney"))
          when :boolean     then options.merge!(:renderer => l("Ext.util.Format.boolRenderer"))
        end
        raise ComponentError, "You must provide header and dataIndex for generate a column model" if options[:header].blank? || options[:dataIndex].blank?
        config[:columns] << Configuration.new(options)
      end
    end
  end
end