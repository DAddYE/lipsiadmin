namespace :lipsiadmin do
  
  namespace :update do
    desc "Update your javascripts from your current lipsiadmin install"
    task :javascripts do
      Dir[File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/javascripts/*.js')].each do |js|
        puts "Coping #{File.basename(js)} ... DONE"
        FileUtils.cp(js, RAILS_ROOT + '/public/javascripts/')
      end
    end
    
    
    namespace :locales do
      desc "Updated the current rails locale and backend locale"
      task :system do
        Dir[File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/config/locales/rails/*.yml')].each do |yml|
          puts "Coping config/locales/rails/#{File.basename(yml)} ... DONE"
          FileUtils.cp(yml, RAILS_ROOT + '/config/locales/rails')
        end
      
        Dir[File.join(File.dirname(__FILE__), '..', '/lipsiadmin_generators/backend/templates/config/locales/backend/*.yml')].each do |yml|
          puts "Coping config/locales/backend/#{File.basename(yml)} ... DONE"
          FileUtils.cp(yml, RAILS_ROOT + '/config/locales/backend')
        end
      end
    
      desc "Updated the current models locales. Use LANGS=en,it,cz"
      task :models => :environment do
        langs = ENV['LANGS'] ? ENV['LANGS'].split(",") : [:en]
        models = Dir["#{RAILS_ROOT}/app/models/*"].collect { |model| File.basename(model, ".rb") }

        for model in models
          # Get the model class
          klass = model.camelize.constantize
          next unless klass.respond_to?(:columns)

          # Init the processing
          print "Processing #{model.humanize}: "
          FileUtils.mkdir_p("#{RAILS_ROOT}/config/locales/models/#{model}")

          # Create models for it and en locales
          langs.each do |lang|
            filename   = "#{RAILS_ROOT}/config/locales/models/#{model}/#{lang}.yml"
            columns    = klass.columns.collect(&:name)
            # If the lang file already exist we need to check it
            if File.exist?(filename)
              locale = File.open(filename).read
              columns.each do |c|
                locale += "        #{c}: #{klass.human_attribute_name(c)}" unless locale.include?("#{c}:")
              end
              print "#{lang} already exist ... "; $stdout.flush
              # Do some ere
            else
              locale     = "#{lang}:" + "\n" +
                           "  activerecord:" + "\n" +
                           "    models:" + "\n" +
                           "      #{model}: #{klass.human_name}" + "\n" +
                           "    attributes:" + "\n" +
                           "      #{model}:" + "\n" +
                           columns.collect { |c| "        #{c}: #{klass.human_attribute_name(c)}" }.join("\n")
              print "#{lang} created new one ... "; $stdout.flush
            end
            File.open(filename, "w") { |f| f.puts locale }
          end
          puts
        end
      end
    end
  end # namespace :update
end # namespace :lipsiadmin

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