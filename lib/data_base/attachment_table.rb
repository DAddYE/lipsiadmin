module Lipsiadmin
  module DataBase
    # This is the table that handle the attachments. 
    # You can define some global info like:
    # 
    #   attachment_styles :thumb, "128x128"
    # 
    # In this way all models that use <tt>has_one_attachment</tt> or 
    # <tt>has_many_attachments</tt> handle a default style called *thumb*
    # 
    # Remember that any model that use <tt>has_one_attachment</tt> or 
    # <tt>has_many_attachments</tt> can override/add styles/validations etc...
    # 
    class AttachmentTable < ActiveRecord::Base
      
      def self.inherited(subclass)#:nodoc:
        super
        subclass.write_inheritable_attribute(:attachment_definitions, {}) if subclass.attachment_definitions.nil?
        subclass.attachment_definitions[subclass.name] = {:validations => {}}.merge(Lipsiadmin::Attachment.options)
        subclass.send(:include, Lipsiadmin::DataBase::UtilityScopes)
        subclass.extend(ClassMethods)
      end
      
      set_table_name "attachments"
      
      belongs_to :attacher, :polymorphic => true
      after_save :save_attached_files
      before_destroy :destroy_attached_files
      define_callbacks :before_post_process, :after_post_process
      define_callbacks :"before_attached_post_process", :"after_attached_post_process"
      
      #validates_presence_of :filename
      
      # Returns the url of the attachment, optionally you can pass the style like url(:thumb)
      def url(style=nil)
        file.to_s(style)
      end
      
      # Returns a <tt>Lipsiadmin::Attachment::Attach</tt> instance
      def file
        @_file ||= Lipsiadmin::Attachment::Attach.new(:attached, self, attachment_definitions)
      end
      
      # Assign a <tt>Lipsiadmin::Attachment::Attach</tt> instance to the current file
      def file=(tempfile)
        file.assign(tempfile)
      end
      
      # Returns true if the file exist
      def file?
        file.exist?
      end
      
      def attachment_definitions=(options)#:nodoc:
        attachment_definitions.merge!(options.symbolize_keys)
      end
      
      # This is the custom instance attachment_definition
      def attachment_definitions#:nodoc:
        @instance_attachment_definitions ||= self.class.attachment_definitions[self.class.name].clone
        return @instance_attachment_definitions
      end
      
      validates_each(:file) do |record, attr, value|
        attachment = record.file
        attachment.send(:flush_errors) unless attachment.valid?
      end
      
      # Perform <tt>file</tt>.save
      def save_attached_files
        logger.info("[Attachment] Saving attachments.")
        file.save
      end
      
      # Perform <tt>file</tt>.destroy
      def destroy_attached_files
        logger.info("[Attachment] Deleting attachments.")
        file.queue_existing_for_delete
        file.flush_deletes
      end
    end
    
    module ClassMethods#:nodoc:

      def attachment_url(url)
        attachment_url_for(self.name, url)
      end

      def attachment_default_url(url)
        attachment_default_url_for(self.name, url)
      end
      
      def attachment_path(path)
        attachment_path_for(self.name, path)
      end
          
      def attachment_styles(name, styles)
        attachment_styles_for(self.name, name, styles)
      end
      
      def attachment_default_style(default_style)
        attachment_default_style_for(self.name, default_style)
      end

      def attachment_whiny(whiny_thumbnails)
        attachment_whiny_for(self.name, whiny_thumbnails)
      end

      def attachment_storage(storage)
        attachment_storage_for(self.name, storage)
      end
      
      def attachment_convert_options(name, convert_options)
        attachment_convert_options_for(self.name, name, convert_options)
      end
      
      def attachment_background(background)
        attachment_background_for(self.name, background)
      end
      
      def attachment_processors(processors)
        attachment_processors_for(self.name, processors)
      end

      def validates_attachment_size(options = {})
        validates_attachment_size_for(self.name, options)
      end

      def validates_attachment_thumbnails(options = {})
        validates_attachment_thumbnails_for(self.name, options)
      end

      def validates_attachment_presence(options = {})
        validates_attachment_presence_for(self.name, options)
      end

      def validates_attachment_content_type(options = {})
        validates_attachment_content_type_for(self.name, options)
      end
    end
    
  end
end
