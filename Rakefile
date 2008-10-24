require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

task :default => [:spec]

desc "Install dependencies"
task :dependencies do
  require ''
  gems = ['addressable/uri', 'treetop']
  gems.each do |g|
    g2 = g.split('/')[0]
    begin
      require g
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

task :spec do
  sh "spec --colour spec"
end

desc "Turns spec results into HTML and publish to web (Tom only!)"
task :spec_html do
  sh "spec --format html:reddy_new_spec.html spec"
  sh "scp reddy_new_spec.html bbcityco@bbcity.co.uk:www/tom/files/rena_new_spec.html"
  sh "rm reddy_new_spec.html"
end

desc "Turns spec results into local HTML"
task :spec_local do
  sh "spec --format html:reddy_new_spec.html spec/"
#  sh "open reddy_new_spec.html"
end

desc "Run specs through RCov"
Spec::Rake::SpecTask.new('coverage') do |t|
  t.spec_files = FileList['spec']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,test,\/Library\/Ruby\/Gems\/1.8\/gems']
end

desc "Runs specs on JRuby"
task :jspec do
  sh "jruby -S `whereis spec` --colour spec"
end

desc "Build gem"
task :build do
  sh "gem build reddy.gemspec"
end