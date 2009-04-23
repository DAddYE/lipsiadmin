# coding: utf-8
module Lipsiadmin
  module Utils
    # Convert common utf-8 chars to html entities, this is beautifull (but the code not)
    # for servers that don't have utf-8 fonts for java. Is a dead simple workaround for
    # avoid losing time.
    module HtmlEntities
       # Convert common utf-8 chars to html entities
      def encode_entities(text)
        map = {
          "'" => "#145",   # ' This is converted for java
          "’" => "rsquo",  # ’
          "°" => "deg",    # °
          "€" => "euro",   # €
          "–" => "ndash",  # –
          "©" => "copy",   # ©
          "«" => "laquo",  # «
          "®" => "reg",    # ®
          "»" => "raquo",  # »
          "à" => "agrave", # à
          "À" => "Agrave", # À
          "á" => "aacute", # á
          "Á" => "Aacute", # á
          "â" => "acirc",  # â
          "Â" => "Acirc",  # Â
          "ä" => "auml",   # ä
          "Ä" => "Auml",   # ä
          "Æ" => "AElig",  # Æ
          "æ" => "aelig",  # æ
          "ç" => "ccedil", # ç
          "Ç" => "Ccedil", # Ç
          "è" => "egrave", # è
          "È" => "Egrave", # È
          "é" => "eacute", # é
          "É" => "Eacute", # É
          "ê" => "ecirc",  # ê
          "Ê" => "Ecirc",  # Ê
          "ë" => "euml",   # ë
          "Ë" => "Euml",   # Ë
          "ì" => "igrave", # ì
          "Ì" => "Igrave", # Ì
          "î" => "icirc",  # î
          "Î" => "Icirc",  # Î
          "ï" => "iuml",   # ï
          "Ï" => "Iuml",   # Ï
          "ô" => "ocirc",  # ô
          "Ô" => "Ocirc",  # Ô
          "ö" => "ouml",   # ö
          "Ö" => "Ouml",   # Ö
          "ò" => "ograve", # ò
          "Ò" => "Ograve", # ò
          "ù" => "ugrave", # ù
          "Ù" => "Ugrave", # Ù
          "û" => "ucirc",  # û
          "Û" => "Ucirc",  # Û
          "ü" => "uuml",   # ü
          "Ü" => "Uuml"    # Ü
        }
        map.each { |k,v| text.gsub!("#{k}", "&#{v};")  }
        return text
      end
    end
  end
end