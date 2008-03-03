require 'spec/rake/spectask'

task :default => [:spec]

desc "Pushes to git"
task :push do
  sh "git push --all"
  sh "growlnotify -m \"Updates pushed\" \"Git\""
end

desc "Runs specs"
task :spec do
  sh "spec --colour --pattern test/spec/*.spec.rb"
end

desc "Turns spec results into HTML"
task :spec_html do
  sh "spec --pattern test/spec/*.spec.rb --format html:rena_new_spec.html"
  sh "scp rena_new_spec.html bbcityco@bbcity.co.uk:www/tom/files/rena_new_spec.html"
  sh "rm rena_new_spec.html"
end