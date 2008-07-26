require 'rails_generator'
require 'rails_generator/commands'
require 'find' 

module Lipsiadmin
  module Commands

    module Base
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

    module Create
      include Base
      
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
        with_source_in(relative_source) do |full, rel|
          if File.directory?(source_path(full))
            directory File.join(relative_destination, rel)
          else
            file full, File.join(relative_destination, rel)
          end
        end
      end

      def append(relative_destination, text, sentinel=nil)
        path = destination_path(relative_destination)
        logger.append relative_destination
        content = File.read(path)
        unless content.include?(text)
          text = sentinel.blank? ? (content + "\n" + text) : content.gsub!(sentinel, sentinel+"\n"+text)
          File.open(path, 'wb') {|f| f.write(text) }
        end
      end
    end # Module Create
  end # Module Commands
end # Module Lipsiadmin
