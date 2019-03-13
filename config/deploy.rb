# frozen_string_literal: true

def get_project_ruby
  rbver = File.expand_path('../../.ruby-version', __FILE__)

  if File.exists?(rbver)
    File.read(rbver)
  else
    "ruby-2.5.3"
  end
end

def get_project_gemset

  rbgemset = File.expand_path('../../.ruby-gemset', __FILE__)

  if File.exits?(rbgemset)
    File.read(rbgemset)
  else
    File.basename(File.dirname(rbgemset))
  end
end


# config valid only for current version of Capistrano
lock '~> 3.11.0'

set :application, 'showtime'
set :repo_url, 'git@github.com:dragonhall/showtime.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/srv/www/showtime.dragonhall.hu/htdocs'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'public/system',
       'public/uploads',
       'public/programs',
       'public/recordings'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

set :rvm_type, :user
#set :rvm_ruby_version, 'ruby-2.4.1@showtime'
set :rvm_ruby_version, "#{get_project_ruby}@#{get_ruby_gemset}"

set :nginx_config_file, -> { "#{fetch(:nginx_config_name)}.conf" }
set :nginx_server_name, 'showtime.dragonhall.hu'

#set :foreman_roles, :all
#set :foreman_init_system, 'systemd'
