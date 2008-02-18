module LipsiaSoft
  module ControllersHelpers

    def header(id, message)
      content_for(:header, "test")
    end
    
    def lipsia_box(value)
      value ? "<img src=\"/images/backend/flag_green.gif\"/>" : "<img src=\"/images/backend/flag_red.gif\"/>"
    end
    
    def lipsia_image(image)
      if image
        return "<div class=\"link\"><a href=\"#\" onclick=\"Ext.Msg.alert('Image','<img src=\\'#{image.public_filename}\\' style=\\'height:#{image.height};width:#{image.width}\\' />');\" \"><img src=\"/images/backend/icons/image.png\" /></a></div>"
      end
    end
    
    def number_to_currency(number, options = {})
      options   = options.stringify_keys
      precision = options["precision"] || 2
      unit      = options["unit"] || "&euro;"
      separator = precision > 0 ? options["separator"] || "." : ""
      delimiter = options["delimiter"] || ","

      begin
        parts = number_with_precision(number, precision).split('.')
        unit + number_with_delimiter(parts[0], delimiter) + separator + parts[1].to_s
      rescue
        number
      end
    end

    def number_with_precision(number, precision=3)
      "%01.#{precision}f" % number
    rescue
      number
    end

    def number_with_delimiter(number, delimiter=",", separator=".")
      begin
        parts = number.to_s.split('.')
        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
        parts.join separator
      rescue
        number
      end
    end
  end
end