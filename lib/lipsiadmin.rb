require 'rexml/document'

module Lipsiadmin
  class << self
    def app_name; 'Lipsiadmin' end
    def url; 'http://rails.lipsiasoft.com/projects/show/lipsiadmin' end
    def help_url; 'http://rails.lipsiasoft.com/wiki/lipsiadmin' end
    def versioned_name; "#{app_name} v#{VERSION}" end
  end
  
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 9

    def self.revision
      revision = nil
      entries_path = "#{RAILS_ROOT}/vendor/plugins/lipsiadmin/.svn/entries"
      if File.readable?(entries_path)
        begin
          f = File.open(entries_path, 'r')
          entries = f.read
          f.close
     	  if entries.match(%r{^\d+})
     	    revision = $1.to_i if entries.match(%r{^\d+\s+dir\s+(\d+)\s})
     	  else
   	        xml = REXML::Document.new(entries)
   	        revision = xml.elements['wc-entries'].elements[1].attributes['revision'].to_i
   	      end
   	    rescue
   	      # Could not find the current revision
   	    end
 	  end
 	  revision
    end

    REVISION = self.revision
    STRING = [MAJOR, MINOR, REVISION].compact.join('.')
    
    def self.to_s; STRING end    
  end
end