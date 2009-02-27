require 'rails_generator'
require 'rails_generator/commands'
require 'find'

module Lipsiadmin#:nodoc:
  module Generator#:nodoc:

    module Lookup#:nodoc:
      def self.included(base)
        base.class_eval do
          alias_method_chain :use_component_sources!, :lipsiadmin
        end
      end
      
      # Append my sources
      def use_component_sources_with_lipsiadmin!
        use_component_sources_without_lipsiadmin!
        sources << Rails::Generator::PathSource.new(:lipsiadmin, "#{File.dirname(__FILE__)}/../lipsiadmin_generators")
      end

    end
  end
end

module Lipsiadmin#:nodoc:
  module Generator#:nodoc:
    module Commands#:nodoc:

      module Base#:nodoc:
        PROTECTED_DIRS = ["app/controllers/",
                          "app/views/",
                          "config/",
                          "app/helpers/",
                          "app/models/",
                          "config/",
                          "lib/",
                          "app/views/layouts/",
                          "public/images/",
                          "public/javascripts/",
                          "public/stylesheet/"]
        
        def with_source_in(path)
          root = source_path(path)
          Find.find(root) do |f|
            Find.prune if File.basename(f) == ".svn"
            Find.prune if File.basename(f) == ".DS_Store"
            full_path = f[(source_root.length)..-1]
            rel_path = f[(root.length)..-1]
            yield full_path, rel_path
          end
        end

        def create_all(relative_source, relative_destination)
          directories = []
          with_source_in(relative_source) do |full, rel|
            if File.directory?(source_path(full))
              directory File.join(relative_destination, rel)
              directories << File.join(relative_destination, rel)
            else
              file full, File.join(relative_destination, rel)
            end
          end
          # Need to do this for remove all directories
          directories.each { |d| directory(d) unless PROTECTED_DIRS.include?(d) }
        end
        
        private
          def render_template_part(template_options)
            # Getting Sandbox to evaluate part template in it
            part_binding = template_options[:sandbox].call.sandbox_binding
            part_rel_path = template_options[:insert]
            part_path = source_path(part_rel_path)

            # Render inner template within Sandbox binding
            rendered_part = ERB.new(File.readlines(part_path).join, nil, '-').result(part_binding)
          end
      end

      module Destroy#:nodoc:
        include Base

        def append(relative_destination, text, sentinel=nil)
          path = destination_path(relative_destination)
          logger.append relative_destination
          content = File.read(path)
          if content.include?(text)
            text = content.gsub(text+"\n", "")
            File.open(path, 'wb') {|f| f.write(text) }
          end
        end
      end # Module Create
      
      module Create#:nodoc:
        include Base

        def append(relative_destination, text, sentinel=nil)
          path = destination_path(relative_destination)
          logger.append relative_destination
          content = File.read(path)
          unless content.include?(text)
            text = sentinel.blank? ? (content + "\n" + text + "\n") : content.gsub(sentinel, sentinel+"\n"+text)
            File.open(path, 'wb') {|f| f.write(text) }
          end
        end
      end # Module Create
    end # Module Commands
  end # Module Utils
end # Module Backend

# For Backend Generators
Rails::Generator::Commands::Create.send(:include, Lipsiadmin::Generator::Commands::Create)
Rails::Generator::Commands::Destroy.send(:include, Lipsiadmin::Generator::Commands::Destroy)
Rails::Generator::Lookup::ClassMethods.send(:include, Lipsiadmin::Generator::Lookup)
Rails::Generator::Base.send(:include, Rails::Generator::Lookup)
