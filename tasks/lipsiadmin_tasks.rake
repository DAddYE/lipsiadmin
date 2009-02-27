namespace :lipsiadmin do
  
  namespace :update do
    desc "Update your javascripts from your current lipsiadmin install"
    task :javascripts do
      puts File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/javascripts/*.js')
      project_dir = RAILS_ROOT + '/public/javascripts/'
      Dir[File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/javascripts/*.js')].each do |js|
        puts "Coping #{File.basename(js)} ... DONE"
        FileUtils.cp(js, project_dir)
      end
    end
  end
end