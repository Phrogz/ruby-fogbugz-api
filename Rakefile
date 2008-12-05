require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
  s.name    = "fogbugz-api"
  s.version = "0.0.5"
  s.date = "2008-12-05"
  s.summary = "Ruby wrapper for FogBugz API"
  
  s.authors = ["Austin Moody","Gregory McIntyre", "George F Murphy"]
  s.email = "gfmurphy@gmail.com"
  s.homepage = "http://github.com/gfmurphy/ruby-fogbugz-api/wikis"
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc"]
  s.rdoc_options << "--inline-source"
  s.extra_rdoc_files = ["README.rdoc","LICENSE","TODO"]
  s.add_dependency "nokogiri", [">= 1.0.4"]
  s.add_dependency "Shoulda", [">= 1.2.0"]
  s.files = FileList['lib/**/*', 'README.rdoc', 'LICENSE', 'TODO', 'fogbugz-api.rb']
end

desc "Run tests"
Rake::TestTask.new('test') do |t|
  t.pattern = 'tests/*_test.rb'
  t.verbose = true
  t.warning = true
end

desc "Package"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.package_dir = 'dist'
  pkg.need_tar = true
end

desc "Generate documentation from source"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'doc'
  rd.title = 'Ruby FogBugz Api Documentation'
  rd.options << "--all"
end

task :package => [:test] do
  puts 'latest version packaged'
end

task :default => [:test]
