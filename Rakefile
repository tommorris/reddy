task :default => [:spec]

task :push do
  sh "git push --all"
end

task :spec do
  sh "spec --colour --pattern test/spec/*.spec.rb"
end