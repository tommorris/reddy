require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'yard'

task :default => [:spec]

desc "Install dependencies"
task :dependencies do
  require ''
  gems = ['addressable/uri']
  gems.each do |g|
    g2 = g.split('/')[0]
    begin
      require g2
    rescue
      sh "sudo gem install " + g2
    end
  end
end

desc "Pushes to git"
task :push do
  sh "git push --all"
  sh "growlnotify -m \"Updates pushed\" \"Git\""
end

desc "Runs specs"
task :spec do
  sh "spec --colour --pattern test/spec/*.spec.rb"
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
#  t.options = ['--any', '--extra', '--opts'] # optional
end

desc "Turns spec results into HTML and publish to web (Tom only!)"
task :spec_html do
  sh "spec --pattern test/spec/*.spec.rb --format html:rena_new_spec.html"
  sh "scp rena_new_spec.html bbcityco@bbcity.co.uk:www/tom/files/rena_new_spec.html"
  sh "rm rena_new_spec.html"
end

desc "Turns spec results into local HTML"
task :spec_local do
  sh "spec --pattern test/spec/*.spec.rb --format html:rena_new_spec.html"
#  sh "open rena_new_spec.html"
end

desc "Run specs through RCov"
Spec::Rake::SpecTask.new('coverage') do |t|
  t.spec_files = FileList['test/spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'test,\/Library\/Ruby\/Gems\/1.8\/gems']
end