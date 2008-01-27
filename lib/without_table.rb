module ActiveRecord
  class WithoutTable < Base
    self.abstract_class = true
    
    def create_or_update
      errors.empty?
    end
    
    class << self
      def columns()
        @columns ||= []
      end
      
      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        reset_column_information
      end
      # Resets all the cached information about columns, which will cause them to be reloaded on the next request.
      def reset_column_information
        generated_methods.each { |name| undef_method(name) }
        @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @generated_methods = nil
      end
    end
  end
end