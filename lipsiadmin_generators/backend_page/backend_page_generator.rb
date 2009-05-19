class ScaffoldingSandbox
  include ActionView::Helpers::ActiveRecordHelper

  attr_accessor :form_action, :singular_name, :suffix, :model_instance
  
  INVALID_COLUMNS = ["_file_name","_content_type","_file_size","created_at","updated_at"]
  
  def all_input_tags(record, record_name, options)
    input_block = options[:input_block] || default_input_block
    record.class.content_columns.collect{ |column| input_block.call(record_name, column) if is_valid?(column) }.compact.join("\n")
  end
  
  def sandbox_binding
    binding
  end
  
  def default_input_block
    Proc.new do |record, column|
"    %tr
      %td=human_name_for :#{record}, :#{column.name}
      %td#{input(record, column.name)}"
    end
  end
  
  def is_valid?(column)
    !INVALID_COLUMNS.find { |c| column.name.include?(c) }
  end
end

class ActionView::Helpers::InstanceTag
  def to_input_field_tag(field_type, options={})
    field_meth = "#{field_type}_field"
    "=#{field_meth} :#{@object_name}, :#{@method_name}#{options.empty? ? '' : ', '+options.inspect}"
  end

  def to_text_area_tag(options = {})
    "=text_area :#{@object_name}, :#{@method_name}#{options.empty? ? '' : ', '+ options.inspect}"
  end

  def to_date_select_tag(options = {})
    "=ext_date_select :#{@object_name}, :#{@method_name}#{options.empty? ? '' : ', '+ options.inspect}"
  end

  def to_datetime_select_tag(options = {})
    "=ext_datetime_select :#{@object_name}, :#{@method_name}#{options.empty? ? '' : ', '+ options.inspect}"
  end
  
  def to_time_select_tag(options = {})
    "=time_select :#{@object_name}, :#{@method_name}#{options.empty? ? '' : ', '+ options.inspect}"
  end
  
  def to_boolean_select_tag(options = {})
    "=check_box :#{@object_name}, :#{@method_name}#{options.empty? ? '' : ', '+ options.inspect}"
  end
end

class BackendPageGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :files, :images, 
                :with_files, :with_images, :with_attachments
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    @controller_name = @name.pluralize
    @with_images = options[:with_images]
    @with_files = options[:with_files]
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    @with_images, @images = (options[:images] && options[:images].size > 0), options[:images] ||= []
    @with_files, @files = (options[:files] && options[:files].size > 0), options[:files] ||= []
    
    @with_attachments = (@with_images || @with_files)
  end


  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}ControllerTest", "#{controller_class_name}Helper"

      attachments = [] 
      attachments.concat(@images).compact!
      attachments.concat(@files).compact!
      
      # Adding new permissions
      permissions = <<-CODE
    role.project_module :#{model_instance.class.table_name} do |project|
      project.menu :list,   "/backend/#{@controller_name}.js" do |submenu|
        submenu.add :new, "/backend/#{@controller_name}/new"
      end
    end 
      CODE
     
      routes = "    backend.resources :#{singular_name.pluralize}"
      # Adding a new permission
      m.append("app/models/account_access.rb", permissions, "# Please don't remove this comment! It's used for auto adding project modules")
      # Adding a new route
      m.append("config/routes.rb", routes, "map.namespace(:backend) do |backend|")
      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers/backend', controller_class_path)
      m.directory File.join('app/views/backend', controller_class_path, controller_file_name)
      m.directory File.join('test/functional/backend', controller_class_path)

      # Depend on model generator but skip if the model exists.
      m.dependency 'model', [singular_name], :collision => :skip, :skip_migration => true

      # Scaffolded forms.
      m.complex_template "form.html.haml",
        File.join('app/views/backend',
                  controller_class_path,
                  controller_file_name,
                  "_form.html.haml"),
        :insert => 'form_scaffolding.html.haml',
        :sandbox => lambda { create_sandbox }


      # Scaffolded views.
      scaffold_views.each do |action|
        m.template "view_#{action}.html.haml",
                   File.join('app/views/backend',
                             controller_class_path,
                             controller_file_name,
                             "#{action}.html.haml"),
                   :assigns => { :action => action }
      end
      # Scaffolded Index Javascript
      m.template "view_index.rjs.erb",
                 File.join('app/views/backend',
                           controller_class_path,
                           controller_file_name,
                           "index.rjs")
      
      # Controller class, functional test, helper, and views.
      m.template 'controller.rb',
                  File.join('app/controllers/backend',
                            controller_class_path,
                            "#{controller_file_name}_controller.rb")

      m.template 'functional_test.rb',
                  File.join('test/functional/backend',
                            controller_class_path,
                            "#{controller_file_name}_controller_test.rb")
                          
      m.readme "../REMEMBER"
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} backend_page ModelName"
    end

    def scaffold_views
      %w(new edit)
    end

    def scaffold_actions
      scaffold_views + %w(index create update destroy)
    end
    
    def model_name 
      class_name.demodulize
    end

    def unscaffolded_actions
      []
    end

    def suffix
      "_#{singular_name}" if options[:suffix]
    end

    def create_sandbox
      sandbox = ScaffoldingSandbox.new
      sandbox.singular_name = singular_name
      begin
        sandbox.model_instance = model_instance      
        sandbox.instance_variable_set("@#{singular_name}", sandbox.model_instance)
      rescue ActiveRecord::StatementInvalid => e
        logger.error "Before updating backend_page from new DB schema, try creating a table for your model (#{class_name})"
        raise SystemExit
      end
      sandbox.suffix = suffix
      sandbox
    end
    
    def model_instance
      base = class_nesting.split('::').inject(Object) do |base, nested|
        break base.const_get(nested) if base.const_defined?(nested)
        base.const_set(nested, Module.new)
      end
      unless base.const_defined?(@class_name_without_nesting)
        base.const_set(@class_name_without_nesting, Class.new(ActiveRecord::Base))
      end
      class_name.constantize.new
    end
end