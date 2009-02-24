module Lipsiadmin
  module DataBase
    module TranslateAttributes
      # Define <tt>method missing</tt> to intercept calls to non-localized methods (eg. +name+ instead of +name_cz+)
      def method_missing(method_name, *arguments)
        # puts "Trying to send '#{method_name}_#{I18n.locale}' to #{self.class}" # uncomment for easy debugging in script/console
        return self.send(:"#{method_name}_#{I18n.locale}") if self.respond_to?(:"#{method_name}_#{I18n.locale}")
        super
      end
    end
  end
end
