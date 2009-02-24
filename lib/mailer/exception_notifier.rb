module Lipsiadmin
  module Mailer
    class ExceptionNotifier < ActionMailer::Base

      @@sender_address = %("Exception Notifier" <exception.notifier@default.com>)
      cattr_accessor :sender_address

      @@recipients_addresses = []
      cattr_accessor :recipients_addresses

      @@extra_options = {}
      cattr_accessor :extra_options

      @@email_prefix = "[ERROR] "
      cattr_accessor :email_prefix
      
      self.mailer_name = "exception"
      self.template_root = "#{File.dirname(__FILE__)}"

      def self.reloadable?() false end

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