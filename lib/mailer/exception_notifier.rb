module Lipsiadmin
  module Mailer
    # This class send notification through mail if an exception
    # occour in a controller.
    class ExceptionNotifier < ActionMailer::Base

      @@sender_address = %("Exception Notifier" <exception.notifier@default.com>)
      cattr_accessor :sender_address

      @@recipients_addresses = []
      cattr_accessor :recipients_addresses

      @@extra_options = {}
      cattr_accessor :extra_options

      @@send_mail = true
      cattr_accessor :send_mail

      @@email_prefix = "[ERROR] "
      cattr_accessor :email_prefix
      
      self.mailer_name = "exception"
      self.template_root = "#{File.dirname(__FILE__)}"

      def self.reloadable?#:nodoc:
        false 
      end
      
      # This method deliver the exception for the given controller and request
      def exception(exception, controller, request)
        content_type "text/plain"

        subject    "#{email_prefix} A #{exception.class} occurred in #{controller.controller_name}##{controller.action_name}"

        recipients recipients_addresses
        from       sender_address

        body       :controller => controller, :request => request,
                   :exception => exception, :host => (request.env["HTTP_X_FORWARDED_HOST"] || request.env["HTTP_HOST"]),
                   :backtrace => exception.backtrace, :extra_options => extra_options
      end

    end
    
  end
end