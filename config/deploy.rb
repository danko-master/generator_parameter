# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'generator_parameter'
set :repo_url, 'git@github.com:danko-master/generator_parameter.git'

set :branch, ENV['BRANCH'] || 'master'
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.1.1@generator_parameter'


# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :ssh_options, {
  forward_agent: true
}

namespace :deploy do

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     # Your restart mechanism here, for example:
  #     # execute :touch, release_path.join('tmp/restart.txt')
  #     # execute "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && #{start_cmd}; fi"
  #     # invoke 'unicorn:restart'
  #   end
  # end

  # after :publishing, :restart

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #     # 
  #   end
  # end

  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command do 
      on roles(:app), except: {no_release: true} do
        execute "chmod a+x /etc/init.d/unicorn_generator_parameter"
        execute "/etc/init.d/unicorn_generator_parameter #{command}"
      end 
    end
  end

  task :setup_config do
    on roles(:app) do
      sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_generator_parameter"
      # run "mkdir -p #{shared_path}/config"
      # put File.read("config/database.example.production.yml"), "#{shared_path}/config/database.yml"
      puts "Now edit the config files in #{shared_path}."
    end
  end

end


# after 'deploy:finalize_update', 'deploy:symlink'
# cap production deploy:compile_assets


