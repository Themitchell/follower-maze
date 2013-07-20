require 'rspec/core/rake_task'

namespace :follower_maze do
  desc "Start the app"
  task :start do
    ruby "bin/run.rb"
  end
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

