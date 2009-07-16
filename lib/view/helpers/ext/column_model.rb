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
        fields.each { |options| add_column(nil, nil, options); }
      end
      
      # Add columns to a Ext.grid.ColumnModel
      #
      #   # Generates: { header: "Created At", dataIndex: "accounts.datetime", sortable => true }
      #   add "Created At", "accounts.datetime", :sortable => true
      # 
      # You can pass :renderer
      #   
      #   # Generates: Ext.util.Format.dateRenderer()
      #   :render   => :time_to_date # This render a datetime to a date
      #   # Generates: Ext.util.Format.dateRenderer()
      #   :renderer => :date
      #   # Generates: Ext.util.Format.dateTimeRenderer()
      #   :renderer => :datetime
      #   # Generates: Ext.util.Format.percentage
      #   :renderer => :percentage
      #   # Generates: Ext.util.Format.eurMoney
      #   :renderer => :eur_money
      #   # Generates: Ext.util.Format.usMoney
      #   :renderer => :us_money
      #   # Generates: Ext.util.Format.boolRenderer
      #   :renderer => :boolean
      #   ...
      #   :render => :capitalize
      #   :render => :file_size
      #   :render => :downcase
      #   :render => :trim
      #   :render => :undef
      #   :render => :upcase
      # 
      # For more see http://extjs.com/deploy/dev/docs/?class=Ext.util.Format
      # 
      # You can pass :editor
      # 
      #   # Generates: { checkbox: true }
      #   :editor => { :xtype => :checkbox, :someConfig => true }
      #   # Generates: new Ext.form.ComboBox({ someConfig => true });
      #   :editor => { :xtype => :combo, :someConfig => true }
      #   # Generates: new Ext.form.DateField({ someConfig => true });
      #   :editor => { :xtype => :datefield, :someConfig => true }
      #   # Generates: new Ext.form.NumberField({ someConfig => true });
      #   :editor => { :xtype => :numberfield, :someConfig => true }
      #   # Generates: new Ext.form.Radio({ someConfig => true });
      #   :editor => { :xtype => :radio, :someConfig => true }
      #   # Generates: new Ext.form.TextArea({ someConfig => true });
      #   :editor => { :xtype => :textarea, :someConfig => true }
      #   # Generates: new Ext.form.TextField({ someConfig => true });
      #   :editor => { :xtype => :textfield, :someConfig => true }
      #   # Generates: new Ext.form.TimeField({ someConfig => true });
      #   :editor => { :xtype => :timefield, :someConfig => true }
      # 
      #   Form components so are:
      #   ---------------------------------------
      #   :checkbox      =>   Ext.form.Checkbox
      #   :combo         =>   Ext.form.ComboBox
      #   :datefield     =>   Ext.form.DateField
      #   :numberfield   =>   Ext.form.NumberField
      #   :radio         =>   Ext.form.Radio
      #   :textarea      =>   Ext.form.TextArea
      #   :textfield     =>   Ext.form.TextField
      #   :timefield     =>   Ext.form.TimeField
      # 
      def add_column(name=nil, data=nil, options={})
        options[:header] = name if name
        options[:dataIndex] = data if data
        
        if options[:editor]
          xtype = options[:editor][:xtype]
          case xtype
            when :checkbox      then options.delete(:editor); options.merge!(:checkbox => true)
            when :combo         then options.merge!(:editor => "new Ext.form.ComboBox(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
            when :datefield     then options.merge!(:editor => "new Ext.form.DateField(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
            when :numberfield   then options.merge!(:editor => "new Ext.form.NumberField(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
            when :radio         then options.merge!(:editor => "new Ext.form.Radio(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
            when :textarea      then options.merge!(:editor => "new Ext.form.TextArea(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
            when :textfield     then options.merge!(:editor => "new Ext.form.TextField(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
            when :timefield     then options.merge!(:editor => "new Ext.form.TimeField(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
            when :datetimefield then options.merge!(:editor => "new Ext.form.DateTimeField(#{Configuration.new(options[:editor]).to_s(3)})".to_l)
          end
        end
        
        case options[:renderer]
          when :time_to_date then options.merge!(:renderer => "Ext.util.Format.dateRenderer()".to_l)
          when :date         then options.merge!(:renderer => "Ext.util.Format.dateRenderer()".to_l)
          when :datetime     then options.merge!(:renderer => "Ext.util.Format.dateTimeRenderer()".to_l)
          when :percentage   then options.merge!(:renderer => "Ext.util.Format.percentage".to_l)
          when :eur_money    then options.merge!(:renderer => "Ext.util.Format.eurMoney".to_l)
          when :us_money     then options.merge!(:renderer => "Ext.util.Format.usMoney".to_l)
          when :boolean      then options.merge!(:renderer => "Ext.util.Format.boolRenderer".to_l)
          when :capitalize   then options.merge!(:renderer => "Ext.util.Format.capitalize".to_l)
          when :file_size    then options.merge!(:renderer => "Ext.util.Format.fileSize".to_l)
          when :downcase     then options.merge!(:renderer => "Ext.util.Format.lowercase".to_l)
          when :trim         then options.merge!(:renderer => "Ext.util.Format.trim".to_l)
          when :undef        then options.merge!(:renderer => "Ext.util.Format.undef".to_l)
          when :upcase       then options.merge!(:renderer => "Ext.util.Format.uppercase".to_l)
        end
        
        raise ComponentError, "You must provide header and dataIndex for generate a column model" if options[:header].blank? || 
                                                                                                     options[:dataIndex].blank?

        config[:columns] << Configuration.new(options)
      end
    end
  end
end