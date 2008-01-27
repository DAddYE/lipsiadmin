module LipsiaSoft
  module IncludeJavascripts
    def include_javascript(partial_path)
      path, partial_name = partial_pieces(partial_path)
      template = File.read("#{base_path}/#{path}/#{partial_name}.ejs")
      template = "<script type=\"text/javascript\" charset=\"utf-8\">\r\n#{template}\r\n</script>"
      erb = ERB.new(template).result(binding)
    end
  end
end