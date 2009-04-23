# This generator bootstraps a Rails project for use with loops
class LoopsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # Generate app/loops directory and an example loop files
      m.directory 'app'
      m.directory 'app/loops'
      m.file      'app/loops/APP_README',     'app/loops/README'
      m.file      'app/loops/simple_loop.rb', 'app/loops/simple_loop.rb'
      
      # Generate script/loops file
      m.directory 'script'
      m.file      'script/loops',             'script/loops', :chmod => 0755
      
      # Generate config/loops.yml file
      m.directory 'config'
      m.file      'config/loops.yml',         'config/loops.yml'
    end
  end

protected

  def banner
    "Usage: #{$0} loops"
  end

end
