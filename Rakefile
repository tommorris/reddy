%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require 'spec/rake/spectask'
require File.dirname(__FILE__) + '/lib/reddy'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('reddy', Reddy::VERSION) do |p|
  p.developer('Tom Morris', 'tom@tommorris.org')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name       = p.name # TODO this is default value
  p.extra_deps		 = [
      ['addressable', '>= 2.0.0'],
      ['treetop', '>= 1.2.4'],
      ['nokogiri', '>= 1.3.3'],
      ['libxml-ruby', '>= 0.8.3'],
      ['whatlanguage', '>= 1.0.0']
  ]
  p.extra_dev_deps = [
      ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store .git tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
#task :default => [:spec, :features]

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
# vim: syntax=Ruby
