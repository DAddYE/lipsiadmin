require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'
require "#{File.dirname(__FILE__)}/lib/version"

PKG_NAME      = 'lipsiadmin'
PKG_VERSION   = Lipsiadmin::VERSION::STRING
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

desc 'Default: install the gem.'
task :default => [:install]

desc 'Generate documentation for the lipsiadmin plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Lipsiadmin'
  rdoc.options << '--line-numbers' << '--inline-source' << '--accessor' << 'cattr_accessor=object'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.template = 'resources/rdoc/horo'
  rdoc.rdoc_files.include('README.rdoc', 'CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Clean up files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "tmp"
  FileUtils.rm_rf "pkg"
end

spec = Gem::Specification.new do |s| 
  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.author            = "Davide D'Agostino"
  s.email             = "d.dagostino@lipsiasoft.com"
  s.homepage          = "http://groups.google.com/group/lipsiadmin"
  s.rubyforge_project = "lipsiadmin"
  s.platform          = Gem::Platform::RUBY
  s.summary           = "Lipsiadmin is a new revolutionary admin for your projects.Lipsiadmin is based on Ext Js 2.0. framework (with prototype adapter) and is ready for Rails 2.0. This admin is for newbie developper but also for experts, is not entirely written in javascript because the aim of developper wose build in a agile way web/site apps so we use extjs in a new intelligent way a mixin of 'old' html and new ajax functions, for example ext manage the layout of page, grids, tree and errors, but form are in html code."
  s.files             = FileList["CHANGELOG", "README.rdoc", "MIT-LICENSE", "Rakefile", "init.rb", "{lipsiadmin_generators,lib,resources,tasks}/**/*"].to_a
  s.has_rdoc          = true
  s.requirements << "ImageMagick"
  s.add_dependency('haml')
  s.add_dependency('rails', '>= 2.2.1')
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

desc "Install the gem locally"
task :install => [:uninstall, :repackage] do
  sh %{sudo gem install pkg/#{PKG_FILE_NAME}.gem --no-ri --no-rdoc}
end

desc "Unistall the gem from local"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{PKG_NAME}} rescue nil
end
 
desc "Generate a gemspec file for GitHub"
task :gemspec do
  File.open("#{spec.name}.gemspec", 'w') do |f|
    f.write spec.to_ruby
  end
end

desc "Publish the API documentation"
task :pdoc => [:rdoc] do 
  Rake::SshDirPublisher.new("root@lipsiasoft.net", "/mnt/www/apps/lipsiasoft/doc", "doc").upload
end

desc "Publish the release files to RubyForge."
task :release => [ :package ] do
  require 'rubyforge'
  require 'rake/contrib/rubyforgepublisher'

  packages = %w( gem tgz zip ).collect{ |ext| "pkg/#{PKG_NAME}-#{PKG_VERSION}.#{ext}" }

  rubyforge = RubyForge.new
  rubyforge.configure
  rubyforge.login
  rubyforge.add_release(PKG_NAME, PKG_NAME, "REL #{PKG_VERSION}", *packages)
end
