require 'tempfile'
require 'data_base/attachment/upfile'
require 'data_base/attachment/iostream'
require 'data_base/attachment/geometry'
require 'data_base/attachment/processor'
require 'data_base/attachment/thumbnail'
require 'data_base/attachment/storage'
require 'data_base/attachment/attach'

if defined? RAILS_ROOT
  Dir.glob(File.join(File.expand_path(RAILS_ROOT), "lib", "attachment_processors", "*.rb")).each do |processor|
    require processor
  end
end

module Lipsiadmin
  module DataBase
    module Attachment

      class << self#:nodoc:
        def included(base) #:nodoc:
          base.extend(ClassMethods)
        end
      end

      module ClassMethods
        
        # Attach a single file/image to your model.
        # 
        #   Examples:
        #     
        #     has_one_attachment                    :image
        #     attachment_styles_for                 :image, :normal, "128x128!"
        #     validates_attachment_presence_for     :image
        #     validates_attachment_size_for         :image, :greater_than => 10.megabytes
        #     validates_attachment_content_type_for :image, "image/png"
        # 
        # Then in your form (with multipart) you can simply add:
        # 
        #   =file_field_tag "yourmodel[image_attributes][file]"
        # 
        # or
        # 
        #   -fields_for "yourmodel[image_attributes][file]", @yourmodel.build_image do |image|
        #     =image.file_field :file
        # 
        def has_one_attachment(name, options={})
          options[:as]         ||= :attacher
          options[:class_name] ||= "Attachment"
          
          # We need to check if the attachment model allow multiple attachments
          multi_attachments = options[:class_name].constantize.column_names.include?("attacher_name")
          
          options[:conditions]   = "attacher_name = '#{name}'" if multi_attachments
          
          has_one name, options
          before_save "before_save_for_#{name}"
          attr_accessor "#{name}_attributes"

          write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
          attachment_definitions[name] = {:validations => {}}.merge(reflections[name].class_name.constantize.attachment_definitions)

          validates_each(name) do |record, attr, value|
            attributes = record.send("#{name}_attributes")
            attributes ||= {}

            attributes.merge!(:attachment_definitions => record.class.attachment_definitions[name])
            file_column = reflections[name].class_name.constantize.new(attributes)
            unless file_column.valid?
              file_column.errors.each do |error, message|
                record.errors.add(name, message) if message
              end
            end
          end

          define_method "before_save_for_#{name}" do
            attributes = send("#{name}_attributes")
            attributes ||= {}
            
            return if attributes[:file].blank?
            
            attributes.merge!(:attachment_definitions => self.class.attachment_definitions[name])
            
            # We need to add the new attacher_name
            attributes.merge!(:attacher_name => name.to_s) if multi_attachments
            
            if file_column = self.send(name)
              file_column.update_attributes(attributes)
            else
              self.send("build_#{name}", attributes)
            end

          end
        end

        # Attach a many files/images to your model.
        # 
        #   Examples:
        #     
        #     has_one_attachment                    :images
        #     attachment_styles_for                 :images, :normal, "128x128!"
        #     validates_attachment_presence_for     :images
        #     validates_attachment_size_for         :images, :greater_than => 10.megabytes
        #     validates_attachment_content_type_for :images, "image/png"
        # 
        # Then in your form (with multipart) you can simply add:
        #   
        #   -fields_for "yourmodel[images_attributes][]", @yourmodel.images.build do |image|
        #     =image.file_field :file
        # 
        def has_many_attachments(name, options = {})
          options[:as]         ||= :attacher
          options[:class_name] ||= "Attachment"
          
          # We need to check if the attachment model allow multiple attachments
          multi_attachments = options[:class_name].constantize.column_names.include?("attacher_name")
          
          options[:conditions]   = "attacher_name = '#{name}'" if multi_attachments

          has_many name, options
          before_save "before_save_for_#{name}"
          attr_accessor "#{name}_attributes"

          write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
          attachment_definitions[name] = {:validations => {}}.merge(reflections[name].class_name.constantize.attachment_definitions)

          validates_each(name) do |record, attr, value|
            attributes = record.send("#{name}_attributes")
            attributes ||= {}

            file_column = nil
            for attribute in attributes
              attribute.merge!(:attachment_definitions => record.class.attachment_definitions[name])
              file_column = reflections[name].class_name.constantize.new(attribute)
              unless file_column.valid?
                file_column.errors.each do |error, message|
                  record.errors.add(name, message) if message
                end
              end
            end
          end

          define_method "before_save_for_#{name}" do
            attributes = send("#{name}_attributes")
            attributes ||= {}

            file_column = nil

            for attribute in attributes
              next if attribute["file"].blank?
              attribute.merge!(:attachment_definitions => self.class.attachment_definitions[name])
              # We need to add the new attacher_name
              attribute.merge!(:attacher_name => name.to_s) if multi_attachments
              self.send(name).build(attribute)
            end

          end
        end
        
        # The full URL of where the attachment is publically accessible. This can just
        # as easily point to a directory served directly through Apache as it can to an action
        # that can control permissions. You can specify the full domain and path, but usually
        # just an absolute path is sufficient. The leading slash *must* be included manually for 
        # absolute paths. The default value is 
        #   "/uploads/:id_:attachment_:style_:basename.:extension". See
        #   Lipsiadmin::Attachment::Attach#interpolate for more information on variable interpolaton.
        #   :url => "/:class/:attachment/:id/:style_:basename.:extension"
        #   :url => "http://some.other.host/stuff/:class/:id_:extension"
        def attachment_url_for(name, url)
          attachment_definitions[name][:url] = url
        end
        
        # The URL that will be returned if there is no attachment assigned. 
        # This field is interpolated just as the url is. The default value is 
        #   "/images/backend/no-image.png"
        #   has_one_attached_file :avatar
        #   attachment_default_url :avatar, "/images/backend/no-image.png"
        #   User.new.avatar.url(:small) # => "/images/backend/no-image.png"        
        def attachment_default_url_for(name, url)
          attachment_definitions[name][:default_url] = url
        end
        
        # The path were the attachment are stored. 
        # The default value is
        #   :rails_root/public/uploads/:id_:attachment_:style_:basename.:extension
        # This value must be in consistency with <tt>url</tt>
        def attachment_path_for(name, path)
          attachment_definitions[name][:path] = path
        end
            
        # A hash of thumbnail styles and their geometries. You can find more about 
        # geometry strings at the ImageMagick website 
        # (http://www.imagemagick.org/script/command-line-options.php#resize). Attachment
        # also adds the "#" option (e.g. "50x50#"), which will resize the image to fit maximally 
        # inside the dimensions and then crop the rest off (weighted at the center). The 
        # default value is to generate no thumbnails.
        def attachment_styles_for(name, style_name, styles)
          attachment_definitions[name][:styles] ||= {}
          attachment_definitions[name][:styles].merge!(style_name => styles)
        end
        
        # The thumbnail style that will be used by default URLs. 
        # Defaults to +original+.
        #   attachment_styles :avatar, :normal, "100x100#"
        #   attachment_default_style :normal
        #   user.avatar.url # => "/avatars/23/normal_me.png"
        def attachment_default_style_for(name, default_style)
          attachment_definitions[name][:default_style] = default_style
        end

        # Will raise an error if Attachment cannot post_process an uploaded file due
        # to a command line error. This will override the global setting for this attachment. 
        # Defaults to false.
        def attachment_whiny_for(name, whiny_thumbnails)
          attachment_definitions[name][:whiny_thumbnails] = whiny_thumbnails
        end

        # Chooses the storage backend where the files will be stored. The current
        # choices are :filesystem and :s3. The default is :filesystem. Make sure you read the
        # documentation for Lipsiadmin::Attachment::Storage::Filesystem and Lipsiadmin::Attachment::Storage::S3
        # for backend-specific options.
        def attachment_storage_for(name, storage)
          attachment_definitions[name][:storage] = storage
        end
        
        # When creating thumbnails, use this free-form options
        # field to pass in various convert command options.  Typical options are "-strip" to
        # remove all Exif data from the image (save space for thumbnails and avatars) or
        # "-depth 8" to specify the bit depth of the resulting conversion.  See ImageMagick
        # convert documentation for more options: (http://www.imagemagick.org/script/convert.php)
        # Note that this option takes a hash of options, each of which correspond to the style
        # of thumbnail being generated. You can also specify :all as a key, which will apply
        # to all of the thumbnails being generated. If you specify options for the :original,
        # it would be best if you did not specify destructive options, as the intent of keeping
        # the original around is to regenerate all the thumbnails when requirements change.
        #   attachment_styles          :avatar, :large,    "300x300"
        #   attachment_styles          :avatar, :negative, "100x100"
        #   attachment_convert_options :avatar, :all,      "-strip"
        #   attachment_convert_options :avatar, :negative, "-negate"
        def attachment_convert_options_for(name, convert_name, convert_options)
          attachment_definitions[name][:convert_options] ||= {}
          attachment_definitions[name][:convert_options].merge!(convert_name => convert_options)
        end
        
        # When processing, if the spawn plugin is installed, processing can be done in
        # a background fork or thread if desired.
        def attachment_background_for(name, background)
          attachment_definitions[name][:background] = background
        end
        
        # Attachment supports an extendible selection of post-processors. When you define
        # a set of styles for an attachment, by default it is expected that those
        # "styles" are actually "thumbnails". However, you can do more than just
        # thumbnail images. By defining a subclass of Lipsiadmin::Attachment::Processor, you can
        # perform any processing you want on the files that are attached. Any file in
        # your Rails app's lib/attachment_processors directory is automatically loaded by
        # Attachment, allowing you to easily define custom processors. You can specify a
        # processor with the :processors option to has_attached_file:
        # 
        #   attachment_styles     :avatar, :text, { :quality => :better }
        #   attachment_processors :avatar, :ocr
        # 
        # This would load the hypothetical class Lipsiadmin::Ocr, which would have the
        # hash "{ :quality => :better }" passed to it along with the uploaded file. For
        # more information about defining processors, see Lipsiadmin::Attachment::Processor.
        # 
        # The default processor is Lipsiadmin::Attachment::Thumbnail. For backwards compatability
        # reasons, you can pass a single geometry string or an array containing a
        # geometry and a format, which the file will be converted to, like so:
        # 
        #   attachment_styles     :avatar, :thumb, ["32x32#", :png]
        # 
        # This will convert the "thumb" style to a 32x32 square in png format, regardless
        # of what was uploaded. If the format is not specified, it is kept the same (i.e.
        # jpgs will remain jpgs).
        # 
        # Multiple processors can be specified, and they will be invoked in the order
        # they are defined in the :processors array. Each successive processor will
        # be given the result of the previous processor's execution. All processors will
        # receive the same parameters, which are what you define in the :styles hash.
        # For example, assuming we had this definition:
        # 
        #   attachment_styles     :avatar, :text, { :quality => :better }
        #   attachment_processors :avatar, :rotator
        #   attachment_processors :avatar, :ocr
        # 
        # then both the :rotator processor and the :ocr processor would receive the 
        # options "{ :quality => :better }". This parameter may not mean anything to one
        # or more or the processors, and they are free to ignore it.        
        def attachment_processors_for(name, processor_name, processors)
          attachment_definitions[name][:processors] ||= {}
          attachment_definitions[name][:processors].merge!(processor_name => processor_processors)
        end

        # Places ActiveRecord-style validations on the size of the file assigned. The
        # possible options are:
        # * +in+: a Range of bytes (i.e. +1..1.megabyte+),
        # * +less_than+: equivalent to :in => 0..options[:less_than]
        # * +greater_than+: equivalent to :in => options[:greater_than]..Infinity
        # * +message+: error message to display, use :min and :max as replacements
        def validates_attachment_size_for(name, options = {})
          min     = options[:greater_than] || (options[:in] && options[:in].first) || 0
          max     = options[:less_than]    || (options[:in] && options[:in].last)  || (1.0/0)
          range   = (min..max)
          helper  = ActionController::Base.helpers

          if options[:message].blank?
            message  = ""
            message << I18n.t("activerecord.errors.messages.greater_than", :count => helper.number_to_human_size(min))    if min > 0
            message << " " + I18n.t("activerecord.errors.messages.less_than", :count => helper.number_to_human_size(max)) if max.to_f.infinite? != 1
          else
            message = options[:message]
          end

          attachment_definitions[name][:validations][:size] = lambda do |attachment, instance|
            if attachment.exist? && !range.include?(attachment.size.to_i)
              message
            end
          end
        end

        # Adds errors if thumbnail creation fails. The same as specifying :whiny_thumbnails => true.
        def validates_attachment_thumbnails_for(name, options = {})
          attachment_definitions[name][:whiny_thumbnails] = true
        end

        # Places ActiveRecord-style validations on the presence of a file.
        def validates_attachment_presence_for(name, options = {})
          message = options[:message] || I18n.t("activerecord.errors.messages.blank")
          attachment_definitions[name][:validations][:presence] = lambda do |attachment, instance|
            message unless attachment.exist?
          end
        end

        # Places ActiveRecord-style validations on the content type of the file
        # assigned. The possible options are: 
        # * +content_type+: Allowed content types.  Can be a single content type 
        #   or an array.  Each type can be a String or a Regexp. It should be 
        #   noted that Internet Explorer upload files with content_types that you 
        #   may not expect. For example, JPEG images are given image/pjpeg and 
        #   PNGs are image/x-png, so keep that in mind when determining how you 
        #   match.  Allows all by default.
        # * +message+: The message to display when the uploaded file has an invalid
        #   content type.
        def validates_attachment_content_type_for(name, *args)
          options = {}
          valid_types = []
          args.each do |variable|
            case variable
              when Hash   then options.merge!(variable)
              else valid_types << variable
            end
          end
          attachment_definitions[name][:validations][:content_type] = lambda do |attachment, instance|
            unless attachment.original_filename.blank?
              content_type = attachment.instance_read(:content_type)
              unless valid_types.any?{ |t| t === content_type }
                options[:message] || I18n.t("activerecord.errors.messages.content_type")
              end
            end
          end
        end
        
        # Returns the attachment definitions defined by each call to
        # has_attached_file.
        def attachment_definitions
          read_inheritable_attribute(:attachment_definitions)
        end

      end

    end
    
  end
end
