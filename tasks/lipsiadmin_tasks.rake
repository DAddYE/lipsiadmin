namespace :lipsiadmin do
  
  namespace :update do
    desc "Update your javascripts from your current lipsiadmin install"
    task :javascripts do
      Dir[File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/javascripts/*.js')].each do |js|
        puts "Coping #{File.basename(js)} ... DONE"
        FileUtils.cp(js, RAILS_ROOT + '/public/javascripts/')
      end
    end
    
    desc "Updated the current rails locale and backend locale"
    task :locales do
      Dir[File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/config/locales/rails/*.yml')].each do |yml|
        puts "Coping config/locales/rails/#{File.basename(yml)} ... DONE"
        FileUtils.cp(yml, RAILS_ROOT + '/config/locales/rails')
      end
      
      Dir[File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/config/locales/backend/*.yml')].each do |yml|
        puts "Coping config/locales/backend/#{File.basename(yml)} ... DONE"
        FileUtils.cp(yml, RAILS_ROOT + '/config/locales/backend')
      end
    end
  end
end

desc "Init the test env and autotest them"
task :autotest => "test:init" do
  system("autotest")
end

namespace :test do
  desc "Init the test database dropping them, recreating and loading fixtures"
  task :init do
    RAILS_ENV = "test"
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:fixtures:load"].invoke
  end
end