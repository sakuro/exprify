# frozen_string_literal: true

require "rspec/core/rake_task"

namespace :examples do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = "examples/**/*_spec.rb"
    t.ruby_opts = %w[-I examples]
  end

  desc "Run all transformer examples"
  task :run do
    examples = FileList["examples/**/*_transformer.rb"]
    examples.each do |file|
      puts "\n=== Running #{File.basename(file)} ==="
      puts "=" * (16 + File.basename(file).length)
      sh "ruby #{file}"
    end
  end
end
