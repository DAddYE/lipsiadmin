module Lipsiadmin
  module Utils
    # This module help you, when you buy the default pdf builder.
    # 
    # Lipsiadmin include a trial fully functional evaluation version, but if you want buy it, 
    # go here: http://pd4ml.com/buy.htm and then put your licensed jar in a directory in your
    # project then simply calling this:
    # 
    #   Lipsiadmin::Utils::PdfBuilder::JARS_PATH = "here/is/my/licensed/pd4ml"
    # 
    # you can use your version without any problem.
    # 
    # By default Lipsiadmin will look into your "vendor/pd4ml" and if:
    # 
    # * pd4ml.jar
    # * ss_css2.jar
    # 
    # are present will use it
    #
    module PdfBuilder
      if File.exist?("#{Rails.root}/vendor/pd4ml/pd4ml.jar") &&
         File.exist?("#{Rails.root}/vendor/pd4ml/ss_css2.jar")

        JARS_PATH = "#{Rails.root}/vendor/pd4ml"
      else
        JARS_PATH = "#{File.dirname(__FILE__)}/../../resources/pd4ml"
      end
      
      PD4RUBY_PATH = "#{File.dirname(__FILE__)}/../../resources/pd4ml/ruby"
    end
  end
end