require "bundler/gem_tasks"
require 'bundler'
Bundler::GemHelper.install_tasks

task :erd do
  FORMAT = 'svg'
  `bundle exec ruby ./etc/erd.rb > ./etc/erd.dot`
  `dot -T #{FORMAT} ./etc/erd.dot -o ./etc/erd.#{FORMAT}`
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task test: :spec

require 'yard'
YARD::Rake::YardocTask.new

task default: [:spec]
