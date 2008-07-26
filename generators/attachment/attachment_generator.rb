class AttachmentGenerator < Rails::Generator::NamedBase
  attr_accessor :attachments, :migration_name
 
  def initialize(args, options = {})
    super
    @class_name, @attachments = args[0], args[1..-1]
  end
 
  def manifest    
    file_name = "add_attachments_to_#{@class_name.underscore}"
    @migration_name = file_name.camelize
    record do |m|
      m.migration_template "paperclip_migration.rb",
                           File.join('db', 'migrate'),
                           :migration_file_name => file_name.underscore
    
      m.puts finish_message
    end
  end 
  
  private 
  def finish_message
    attached = @attachments.collect { |a| "has_attached_file :#{a.downcase}, :styles => { :normal => \"780x360\", :medium => \"400x350\", :thumb => \"128x128!\" }" }
    <<-MESSAGE
        
==============================================================================================

  Add to app/models/#{@class_name.underscore}.rb some like this
  
  #{attached.join("\n  ")}
  
  For more info please visit http://thoughtbot.com/projects/paperclip

==============================================================================================
    MESSAGE
  end   
 
end