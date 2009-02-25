module Lipsiadmin
  module DataBase
    # With this method we can translate define and automatically translate columns for 
    # the current rails locale.
    # 
    # Defining some columns like these:
    # 
    #   m.col :string, :name_it, :name_en, :name_cz
    #   m.col :text, :description_it, :description_en, :description_cz
    #   
    # we can call
    #   
    #   myinstance.name
    # 
    # or
    # 
    #   puts myinstance.description
    #   
    # Lipsiadmin look for name_#{I18n.locale}
    # 
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
