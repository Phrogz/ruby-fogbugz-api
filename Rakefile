require 'rake/testtask'
require 'rake/rdoctask'

task :default => [:test]

desc "Run tests"
Rake::TestTask.new('test') do |t|
  t.pattern = 'tests/*_test.rb'
  t.verbose = true
  t.warning = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'doc'
  rd.title = 'Ruby FogBugz Api Documentation'
  rd.options << "--all"
end
