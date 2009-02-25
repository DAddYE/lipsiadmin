module Lipsiadmin
  module Controller
    # This module are raised when an exception fire up in controllers.
    # 
    # Now you can personalize exception and simplify the layout using templates in:
    # 
    #   app/views/exception
    # 
    # when an exception is raised it try to send an email, and for send an email 
    # you need to configure in enviroment or in an initializer some like this:
    #
    #   Examples:
    #     
    #     Lipsiadmin::Mailer::ExceptionNotifier.sender_address       = %("Exception Notifier" <server1@lipsiasoft.com>)
    #     Lipsiadmin::Mailer::ExceptionNotifier.recipients_addresses = %(info@lipsiasoft.com)
    #     Lipsiadmin::Mailer::ExceptionNotifier.email_prefix         = "[Your Project]"
    # 
    module Rescue
      
      def self.included(base)#:nodoc:
        base.class_eval do
          alias_method_chain :rescue_action_in_public, :notifier
        end
      end

      # Overwrite to implement public exception handling (for requests answering false to <tt>local_request?</tt>).  By
      # default will call render_optional_error_file.  Override this method to provide more user friendly error messages.
      def rescue_action_in_public_with_notifier(exception) #:doc:
        response_code = response_code_for_rescue(exception)
        status        = interpret_status(response_code)[0,3]
        respond_to do |format|
          format.html { render :template => "/exceptions/#{status}", :status => status }
          format.all  { render :nothing => true, :status => true }
          #format.js   { render(:update) { |page| page.call "alert", interpret_status(response_code)  } }
        end
      rescue Exception => e
        logger.error e.message
        erase_results
        rescue_action_in_public_without_notifier(exception)
      ensure
        if response_code != :not_found
          Lipsiadmin::Mailer::ExceptionNotifier.deliver_exception(exception, self, request)
        end
      end
      
    end

  end
end