# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# guard :spring, bundler: true do
#   watch('Gemfile.lock')
#   watch(%r{^config/})
#   watch(%r{^config.ru$})
#   watch(%r{^spec/(support|factories)/})
#   watch(%r{^app/assets/config/manifest.js})
# end

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

# Guard-Rails supports a lot options with default values:
# daemon: false                        # runs the server as a daemon.
# debugger: false                      # enable ruby-debug gem.
# environment: 'development'           # changes server environment.
# force_run: false                     # kills any process that's holding the listen port
#                                      # before attempting to (re)start Rails.
# pid_file: 'tmp/pids/[RAILS_ENV].pid' # specify your pid_file.
# host: 'localhost'                    # server hostname.
# port: 3000                           # server port number.
# root: '/spec/dummy'                  # Rails' root path.
# server: thin                         # webserver engine.
# start_on_start: true                 # will start the server when starting Guard.
# timeout: 30                          # waits untill restarting the Rails server, in seconds.
# zeus_plan: server                    # custom plan in zeus, only works with `zeus: true`.
# zeus: false                          # enables zeus gem.
# CLI: 'rails server'                  # customizes runner command. Omits all options except `pid_file`!

guard :rails, CLI: 'rails server -u puma -b 0.0.0.0 -p 3000' do
  watch('Gemfile.lock')
  watch(%r{^config/.*})
  watch(%r{^app/assets/config/manifest.js})
end

# NOTE: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

# guard :rspec, cmd: "bundle exec rspec" do
#  require "guard/rspec/dsl"
#  dsl = Guard::RSpec::Dsl.new(self)
#
#  # Feel free to open issues for suggestions and improvements
#
#  # RSpec files
#  rspec = dsl.rspec
#  watch(rspec.spec_helper) { rspec.spec_dir }
#  watch(rspec.spec_support) { rspec.spec_dir }
#  watch(rspec.spec_files)
#
#  # Ruby files
#  ruby = dsl.ruby
#  dsl.watch_spec_files_for(ruby.lib_files)
#
#  # Rails files
#  rails = dsl.rails(view_extensions: %w(erb haml slim))
#  dsl.watch_spec_files_for(rails.app_files)
#  dsl.watch_spec_files_for(rails.views)
#
#  watch(rails.controllers) do |m|
#    [
#      rspec.spec.call("routing/#{m[1]}_routing"),
#      rspec.spec.call("controllers/#{m[1]}_controller"),
#      rspec.spec.call("acceptance/#{m[1]}")
#    ]
#  end
#
#  # Rails config changes
#  watch(rails.spec_helper)     { rspec.spec_dir }
#  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
#  watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }
#
#  # Capybara features specs
#  watch(rails.view_dirs)     { |m| rspec.spec.call("features/#{m[1]}") }
#  watch(rails.layouts)       { |m| rspec.spec.call("features/#{m[1]}") }
#
#  # Turnip features and steps
#  watch(%r{^spec/acceptance/(.+)\.feature$})
#  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) do |m|
#    Dir[File.join("**/#{m[1]}.feature")][0] || "spec/acceptance"
#  end
# end

### Guard::Resque
#  available options:
#  - :task (defaults to 'resque:work' if :count is 1; 'resque:workers', otherwise)
#  - :verbose / :vverbose (set them to anything but false to activate their respective modes)
#  - :trace
#  - :queue (defaults to "*")
#  - :count (defaults to 1)
#  - :environment (corresponds to RAILS_ENV for the Resque worker)
guard 'resque', environment: 'development', queue: 'default,mailers,streaming,recording' do
  watch(%r{^app/jobs/(.+)\.rb$})
end

guard 'resque', environment: 'development', task: 'resque:scheduler' do
  watch(%r{^app/jobs/(.+)\.rb$})
end
