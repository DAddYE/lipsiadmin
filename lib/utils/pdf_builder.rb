module Lipsiadmin
  module Utils
    # This module help you, when you buy the default pdf builder.
    # 
    # Lipsiadmin include a trial fully functional evaluation version, but if you want buy it, 
    # go here: http://pd4ml.com/buy.htm and then put your licensed jar in a directory in your
    # project then simply calling this:
    # 
    #   Lipsiadmin::Utils::PdfBuilder.jars_path = "here/is/my/licensed/pd4ml"
    #   Lipsiadmin::Utils::PdfBuilder.view_path = "keep/template/in/other/path"
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
    class PdfBuilder
      if File.exist?("#{Rails.root}/vendor/pd4ml/pd4ml.jar") &&
         File.exist?("#{Rails.root}/vendor/pd4ml/ss_css2.jar")

        @@jars_path = "#{Rails.root}/vendor/pd4ml"
      else
        @@jars_path = "#{File.dirname(__FILE__)}/../../resources/pd4ml"
      end
      
      @@pd4ruby_path = "#{File.dirname(__FILE__)}/../../resources/pd4ml/ruby"
      @@view_path    = "#{RAILS_ROOT}/app/views/pdf"
      
      cattr_accessor :jars_path
      cattr_accessor :pd4ruby_path
      cattr_accessor :view_path
    end
  end
end