# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

Dir[File.join(__dir__, "tasks", "*.rake")].sort.each {|task| load task }

RSpec::Core::RakeTask.new(:spec)

task default: :spec
task test: :spec

task :console do
  exec "irb -I lib -r yandex360.rb"
end
