require 'rexml/document'

module Lipsiadmin
  class << self
    def app_name; 'Lipsiadmin' end
    def url; 'http://rails.lipsiasoft.com/projects/show/lipsiadmin' end
    def help_url; 'http://rails.lipsiasoft.com/wiki/lipsiadmin' end
    def versioned_name; "#{app_name} v#{VERSION}" end
  end
  
  module VERSION #:nodoc:
    module_function
  
    REPOSITORY_ROOT = "#{RAILS_ROOT}/vendor/plugins/lipsiadmin"
     
    def branches
      %x(cd #{REPOSITORY_ROOT}; git-branch).map { |branch| extract_branch_name(branch) }
    end
 
    def extract_branch_name(branch_name)
      branch_name.gsub!("\s.+", "")
      branch_name.gsub!("\*", "")
      branch_name.strip
    end
    
    def tag_list
      %x(cd #{REPOSITORY_ROOT}; git-tag --)
    end
 
    def rev_list(branch_name)
      %x(cd #{REPOSITORY_ROOT}; git-rev-list #{branch_name} --)
    end
 
    def rev_list_all_branches
      %x(cd #{REPOSITORY_ROOT}; git-rev-list #{branches.join(" ")} --)
    end
 
    def find_commits(branch_name=nil)
      branch_name ?  rev_list(branch_name) : rev_list_all_branches
    end
 
    def commits(branch_name=nil)
      commits = branch_name ? find_commits(branch_name) : find_commits
      @commits = commits.split.reverse
    end
    
    def to_s 
      if File.exist?(REPOSITORY_ROOT+"/.git")
        version  = [tag_list.split.last]
        version << commits.size if RAILS_ENV == "development"
        return version.join(".")
      else
         return "0.9"
      end
    end
  end
end