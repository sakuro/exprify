# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"
require "rubocop/rake_task"

CLEAN.include("coverage")
CLEAN.include(".rspec_status")

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

Dir.glob("lib/tasks/*.rake").each { load it }

task default: %i[spec rubocop]
