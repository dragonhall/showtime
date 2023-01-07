# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  ## We do not provide Rubocop tasks in some cases
  puts ' !! Rubocop tasks will be unavailable'
end
