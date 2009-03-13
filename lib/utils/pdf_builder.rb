module Lipsiadmin
  module Utils
    # This module help you, when you buy the default pdf builder.
    # 
    # Lipsiadmin include a trial fully functional evaluation version, but if you want buy it, 
    # go here: http://pd4ml.com/buy.htm and then put your licensed jar in a directory in your
    # project then simply calling this:
    # 
    #   Lipsiadmin::Utils::PdfBuilder::JAR_PATH = "here/is/my/licensed/pd4ml"
    # 
    # you can use your version without any problem.
    # 
    module PdfBuilder
      JAR_PATH = "../../resources"
    end
  end
end