# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

Dir[File.join(__dir__, "tasks", "*.rake")].sort.each {|task| load task }

RSpec::Core::RakeTask.new(:spec)

# Run apart from the rest: it requires rails, and RSpec loads every spec file
# into one process, so including it would mean Rails is loaded while the other
# examples run. They are there to show the gem works without it.
RSpec::Core::RakeTask.new("spec:railtie") do |task|
  task.pattern = "spec/lib/yandex360/railtie_spec.rb"
  task.rspec_opts = "--options /dev/null --require spec_helper"
end

# The Railtie run goes first so the coverage report left on disk is the one
# from the full suite, which is what gets uploaded.
task spec_all: ["spec:railtie", :spec]

task default: :spec_all
task test: :spec_all

task :console do
  exec "irb -I lib -r yandex360.rb"
end
