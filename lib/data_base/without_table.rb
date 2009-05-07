module Lipsiadmin
  module DataBase
    # This class create a *fake* table that can be usefull if you need for example
    # perform validations. Take a look to this test case:
    # 
    #   Examples:
    # 
    #     class Contact < Lipsiadmin::DataBase::WithoutTable
    #       column :name, :string
    #       column :company, :string
    #       column :telephone, :string
    #       column :email, :string
    #       column :message, :text
    #     
    #       validates_presence_of :name, :message
    #       validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    #     end
    # 
    # Now we need to validate a contact, and if the validations is okey send an email or if not raise errors
    # 
    #   @contact = Contact.new(params[:contact])
    #   if @contact.valid? 
    #     Notifier.deliver_support_request(@contact)
    #   else
    #     flash[:notice] = "There are some problems"
    #     render :action => :support_request
    #   end
    # 
    class WithoutTable < ActiveRecord::Base
      self.abstract_class = true

      def create_or_update#:nodoc:
        errors.empty?
      end

      class << self
        # Returns columns for this *fake* table
        def columns()
          @columns ||= []
        end
        
        # Define columns for a this *fake* table
        def column(name, sql_type = nil, default = nil, null = true)
          columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
          reset_column_information
        end
        
        # Resets all the cached information about columns, which will cause them to be reloaded on the next request.
        def reset_column_information
          generated_methods.each { |name| undef_method(name) }
          @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @generated_methods = nil
        end
      end
    end
  end
end