module Lipsiadmin
  module Ext
    # Ext configuration used by components
    # 
    #   Generates: { name: 'name', handler: function(){ alert('Hello World') } }
    #
    class Configuration < Hash
      
      def initialize(hash)#:nodoc:
        hash.each { |k,v| self[k] = v }
      end
      
      # Returns the configuration as a string.
      # Optionally you can specify the indentation spaces.
      def to_s(indent=1)
        return if self.empty?
        i = ("  "*indent)
        s = self.size > 0 ? "\n" : "  "
        "{#{s}" + self.reject { |k,v| k.blank? || v.to_s.blank? }.collect { |k,v| "#{i*2}#{k}: #{s(v)}" if k != :var }.join(",#{s}") + "#{s}#{i}}"
      end
      
      private
        def javascript_object_for(object)
          case object
            when Configuration
              object.to_s(2)
            when Array
              "[" + object.collect { |o| s(o) }.join(",") + "]"
            else
              object.respond_to?(:to_json) ? object.to_json : object.inspect
          end
        end
        alias_method :s, :javascript_object_for
    end
  end
end