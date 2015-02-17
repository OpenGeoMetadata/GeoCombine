require 'bundler/gem_tasks'

Dir.glob('lib/tasks/*.rake').each { |r| load r}

desc 'Run console for development'
task :console do
  require 'irb'
  require 'irb/completion'
  require 'irb/ext/save-history'
  require 'geo_combine'
  ARGV.clear
  IRB.start
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
