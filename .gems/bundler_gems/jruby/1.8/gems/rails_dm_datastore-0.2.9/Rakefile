require 'rubygems'
require 'rake'

DM_VERSION = "0.10.2"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rails_dm_datastore"
    gem.summary = %Q{Generators for dm on gae}
    gem.description = %Q{Integrate datamapper to Rails for the Google App Engine}
    gem.email = ["joshsmoore@gmail.com", "woodie@netpress.com"]
    gem.homepage = "http://github.com/joshsmoore/dm-rails-gae"
    gem.authors = ["Josh S Moore", "John Woodell"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency 'dm-core', DM_VERSION
    gem.add_dependency 'dm-ar-finders', DM_VERSION
    gem.add_dependency 'dm-timestamps', DM_VERSION
    gem.add_dependency 'dm-validations', DM_VERSION
    gem.add_dependency 'dm-appengine'
    gem.add_dependency 'rails_appengine'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dm-rails-gae #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
