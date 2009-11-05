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
    # If you want to override our default templates you can do easly with:
    # 
    #   Lipsiadmin::Ext::Component.template_paths.unshift("/path/to/my/js/templates")
    # 
    class Component      
      @@template_paths = ["#{File.dirname(__FILE__)}/templates", "#{Rails.root}/app/views/backend"]
      cattr_accessor :template_paths
      
      def initialize(klass, options={}, &block)#:nodoc:
        @klass  = klass
        @prefix = options.delete(:prefix)
        @var    = options.delete(:var)
        @config = Configuration.new(options)
        @before, @after = [], []
        @items, @un  = {}, {}
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
        @var = nil            if @var.blank?
        @config.delete(:var)  if @config[:var].blank?
        
        # Return a correct var
        current_var = (@var || @config[:var] || build_var)
        @prefix.to_s + current_var.to_s
      end

      # Define the title of the component.
      # 
      # Every component can have a title, because in Lipsiadmin we use it 
      # as a "pagetitle", but if you need it as a config you can provide global = false
      # 
      def title(title, global=true)
        global ? (before << "Backend.app.setTitle(#{title.to_json});") :  config[:title] = title
      end
      
      # Write the the configuration of object from an hash
      #
      def config=(options={})
        @config = Configuration.new(options)
      end

      # Return the configuration hash
      #
      def config
        @config
      end
      
      def method_missing(method, arguments=nil, &block)#:nodoc:
        if method.to_s =~ /^get_/
          @config[method.to_s.gsub(/^get_/, "").to_sym]
        else
          add_object(method, arguments)
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
      #     grid.on :dblclick do |p|
      #       p.call "edit"
      #       p.call "new"
      #       p.ext_alert "Hello", "world"
      #     end
      # 
      def on(event, function=nil, scope=nil, &block)
        # Remove old handlers
        un(event)
        @un[event.to_sym] = false # we need to reset it
        scope = ", #{scope.to_l}" unless scope.blank?        
        if function
          after << "#{get_var}.on(#{event.to_json}, #{function}#{scope});"
        else
          generator = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(self, &block)
          after << "#{get_var}.on(#{event.to_json}, function() { \n  #{generator.to_s.gsub("\n", "\n  ")}\n}#{scope});"
        end
      end
      
      # Remove a listener
      #   
      #   Example: grid.un(:dblclick)
      # 
      def un(event)
        @un[event.to_sym] = true
        found = @after.delete_if { |s| s.start_with?("#{get_var}.on(#{event.to_json}") if s.is_a?(String) }
        after << "#{get_var}.un(#{event.to_json})" unless found
      end
      
      # Generates and add new Component for generate on the fly ExtJs Objects
      # 
      #   Examples:
      # 
      #     # Generates:
      #     #   var panel = new Ext.Panel({
      #     #     id: 'testPanel',
      #     #     region: 'center',
      #     #     ...
      #     #   })
      #     #   mycmp.add(panel)
      #     #   
      #     mycmp.add "Ext.Panel" do |panel| 
      #       panel.id "testPanel",
      #       panel.region :center
      #       ...
      #     end
      # 
      def add(klass, options={}, &block)
        add_object(Component.new(klass, options.merge(:prefix => get_var), &block))
      end
      
      # Used by ActionView::Helpers::PrototypeHelper::JavaScriptGenerator
      def with_output_buffer(buf = '')#:nodoc:
        yield
      end
      
      # Returns the javascript for current component
      # 
      #   # Generates: var rowSelectionModel = Ext.grid.RowSelectionModel();
      #   Component.new("Ext.grid.RowSelectionModel").to_s
      # 
      def to_s(options={})
        script = returning [] do |script|
          script << @before.uniq.compact.join("\n\n")
          script << "var #{get_var} = new #{@klass}(#{config.to_s});"
          script << @after.uniq.compact.join("\n\n")
        end
        script.delete_if { |s| s.blank? }.join("\n\n")
      end
      
      def raise_error(error)#:nodoc:
         raise ComponentError, error
      end

      private
        def render_javascript(template, assigns)
          assigns.each { |key, value| instance_variable_set("@#{key}", value) }
          path = template_paths.find { |f| File.exist?(File.join(f, "#{template}.js.erb")) }
          raise_error "Sorry but we didn't found the template #{template}.js.erb in your template_paths" unless path
          template = File.read(File.join(path, "#{template}.js.erb"))
          return ERB.new(template).result(binding)
        end
        
        def add_object(name, object)
          if object.class == Component || object.class.superclass == Component
            object.prefix = get_var
            @before.delete_if { |b| b.start_with?("var #{object.get_var} = new") }
            @before << object.to_s
            @config[name.to_sym] = object.get_var.to_l
            @items.merge!({ name.to_s.to_sym => object })
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