module Lipsiadmin#:nodoc:
  module Ext#:nodoc:
    
    class ComponentError < StandardError; end#:nodoc:
    
    # This is the base class of ext components
    # 
    # You can generate your custom ExtJs objects like:
    # 
    #   # Generates: 
    #   #   var groupingView = Ext.grid.GroupingView({
    #   #     forceFit: true
    #   #   });
    # 
    #   Component.new("Ext.grid.GroupingView", { :forceFit => true });
    # 
    class Component      

      def initialize(klass, options={}, &block)#:nodoc:
        @klass  = klass
        @prefix = options.delete(:prefix)
        @var    = options.delete(:var)
        @config = Configuration.new(options)
        @before, @after = [], []
      
        if self.class == Component && block_given?
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
      #   store.var "myVar"
      #
      def var(var)
        @var = var
      end

      # Get the var used by the component defaults is the id of the component
      #      
      def get_var
        # I will nillify obj if they are blank
        @var = nil            if @var == ""
        @config.delete(:var)  if @config[:var] == ""
        # Return a correct var
        current_var = (@var || @config[:var] || build_var)
        @prefix.to_s + current_var.to_s
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
          add_object(method, arg)
        end
      end
      
      # Set the prefix for the var of the component.
      # This is usefull when for example we are using two grids 
      # for solve conflict problems.
      # 
      def prefix=(value)
        @prefix = value
      end
      
      # Returns an array of javascripts to add before component is rendered.
      #      
      def before
        @before
      end
      
      # Returns an array of javascripts to add afters component is rendered.
      #
      def after
        @after
      end
      
      # Generates a new handler for the given component
      # 
      #   Examples:
      #     
      #     # Generates:
      #     #     grid.on("dblclick", function() { 
      #     #       edit();
      #     #       new();
      #     #       Ext.Msg.alert("Hello", "world");
      #     #     });
      # 
      #     grid.on :dblclick do |p|
      #       p.call "edit"
      #       p.call "new"
      #       p.ext_alert "Hello", "world"
      #     end
      def on(event, function=nil, scope=nil, &block)
        # Remove old handlers
        remove_listener(event)
        scope = ", #{l(scope)}" unless scope.blank?        
        if function
          after << "#{get_var}.on(#{event.to_json}, #{function}#{scope});"
        else
          generator = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(self, &block)
          after << "#{get_var}.on(#{event.to_json}, function() { #{generator.to_s.gsub("\n", "\n  ")}\n}#{scope});"
        end
      end
      alias_method :add_listener, :on
      
      # Remove a listener
      # 
      #   Example: grid.remove_listener(:dblclick)
      def remove_listener(event)
        @after.delete_if { |s| s.start_with?("#{get_var}.on(#{event.to_json}") if s.is_a?(String) }
      end
      
      # Generates a new Component for generate on the fly ExtJs Objects
      # 
      #   Examples:
      # 
      #     # Generates:
      #     #   var myComponent = new MyComponent({
      #     #     default: true
      #     #   });
      #     grid.my_component grid.new_component("MyComponent") { |p| p.default true }
      # 
      def new_component(klass, options={}, &block)
        Component.new(klass, options, &block)
      end
      
      # Used by ActionView::Helpers::PrototypeHelper::JavaScriptGenerator
      def with_output_buffer(buf = '')#:nodoc:
        yield
      end
      
      
      # Returns the javascript for current component
      #
      #   # Generates: var rowSelectionModel = Ext.grid.RowSelectionModel();
      #   Component.new("Ext.grid.RowSelectionModel")
      # 
      def to_s
        script = []
        script << @before.uniq.compact.join("\n\n")
        script << "var #{get_var} = new #{@klass}(#{config.to_s});"
        script << @after.uniq.compact.join("\n\n")
        script.delete_if { |s| s.blank? }.join("\n\n")
      end
      
      def raise_error(error)#:nodoc:
         raise ComponentError, error
      end
      
      # Returns an object whose <tt>to_json</tt> evaluates to +code+. Use this to pass a literal JavaScript 
      # expression as an argument to another JavaScriptGenerator method.
      #
      def literal(code)
        ActiveSupport::JSON::Variable.new(code.to_s)
      end
      alias_method :l, :literal

      private
        def render_javascript(template, assigns)
          assigns.each { |key, value| instance_variable_set("@#{key}", value) }
          template = File.read("#{File.dirname(__FILE__)}/templates/#{template}.js.erb")
          return ERB.new(template).result(binding)
        end
        
        def add_object(name, object)
          if object.class == Component || object.class.superclass == Component
            object.prefix = get_var
            @before.delete_if { |b| b.start_with?("var #{object.get_var} = new") }
            @before << object.to_s
            @config[name.to_sym] = l(object.get_var)
          else
            @config[name.to_sym] = object
          end
        end
        
        def build_var
          returning "" do |val|
            if @prefix.blank?
              val << @klass.split(".").last.demodulize.slice(0..0).downcase
              val << @klass.split(".").last.demodulize.slice(1..-1)
            else
              val << @klass.split(".").last.demodulize
            end
          end
        end
    end
  end
end