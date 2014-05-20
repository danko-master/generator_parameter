require 'rvm/capistrano'
require "bundler/capistrano"

server "54.188.217.10", :web, :app, :db, primary: true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "sac.pem")]

set :user,         "ubuntu"
set :application,  "generator_parameter"
set :use_sudo,     false
set :rails_env,    "production"
set :deploy_to,    "/home/#{user}/apps/#{application}"
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid,  "#{deploy_to}/shared/pids/unicorn.pid"
set :start_cmd,    "bundle exec unicorn_rails -c #{unicorn_conf} -E #{rails_env} -D"

# ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :scm, "git"

set :rvm_ruby_string, 'ruby-2.1.1@generator_parameter'
set :rvm_type, :user

set :repository,  "git@github.com:danko-master/generator_parameter.git"
set :branch,      "master"
set :deploy_via, :remote_cache

# set :copy_exclude, %w(.git .gitignore)

# set :deploy_via, :copyset :branch, "master"

set :keep_releases, 5


namespace :deploy do
  desc "Start unicorn"
  task :start do
    run "cd #{deploy_to}/current && #{start_cmd}"
  end

  desc "Stop unicorn"
  task :stop do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end

  desc "Restart unicorn"
  task :restart do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && #{start_cmd}; fi"
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
  # after "deploy:finalize_update", 'deploy:assets:precompile'
end

