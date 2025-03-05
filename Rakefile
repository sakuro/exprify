# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"

CLEAN.include("coverage")
CLEAN.include(".rspec_status")
CLEAN.include(".yardoc")
CLEAN.include("doc")

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
  t.options = ["--markup", "markdown"]
end

Dir.glob("lib/tasks/*.rake").each { load it }

task default: %i[spec rubocop yard]
