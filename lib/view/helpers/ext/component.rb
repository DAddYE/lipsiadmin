module Lipsiadmin#:nodoc:
  module Ext#:nodoc:
    
    class ComponentError < StandardError; end#:nodoc:
    
    # This is the base class of ext components
    class Component      

      def initialize(options={}, &block)
        @config = Configuration.new(options)
        @before, @after = [], []
        if block_given?
          yield self
        end
      end
      
      # The id of the component
      #
      def id(new_id)
        @config[:id] = new_id
      end
      
      # Set var used by the component
      # 
      #   Generates: var myVar = new Ext.Grid({...});
      #
      def var(var)
        @var = var
      end

      # Get the var used by the component defaults is the id of the component
      #      
      def get_var
        # I will nillify obj if they are blank
        @var = nil     if @var == ""
        @config[:var]  if @config[:var] == ""
        # Return a correct var
        @var || @config[:var] || (self.class.name.demodulize.slice(0..0).downcase + self.class.name.demodulize.slice(1..-1))
      end
      
      # Write the the configuration of object from an hash
      #
      def config=(options={})
        @config = Configuration.new(options)
      end

      # Read the the configuration of object from an hash
      #
      def config
        @config
      end
      
      def method_missing(method, arg=nil)#:nodoc:
        if method.to_s.start_with?("get_")
          @config[method.to_s.gsub("get_", "").to_sym]
        else
          @config[method.to_sym] = arg
        end
      end
      
      # Return the array JavaScript to add before component.
      #      
      def before
        @before
      end

      # Return the raw JavaScript to add before component.
      #      
      def before_js
        @before.uniq.compact.join("\n\n") + "\n\n"
      end
      
      # Return the array JavaScript to add after component.
      #      
      def after
        @after
      end
      
      # Return the raw JavaScript to add after component.
      #      
      def after_js
        "\n\n" + @after.uniq.compact.join("\n\n")
      end
      
      # Returns an object whose <tt>to_json</tt> evaluates to +code+. Use this to pass a literal JavaScript 
      # expression as an argument to another JavaScriptGenerator method.
      #
      def literal(code)
        ActiveSupport::JSON::Variable.new(code.to_s)
      end
      alias_method :l, :literal

      private
        def javascript_object_for(object)
          object.respond_to?(:to_json) ? object.to_json : object.inspect
        end
        alias_method :s, :javascript_object_for
        
        def render_javascript(template, assigns)
          assigns.each { |key, value| instance_variable_set("@#{key}", value) }
          template = File.read("#{File.dirname(__FILE__)}/templates/#{template}.js.erb")
          return ERB.new(template).result(binding)
        end
    end
  end
end