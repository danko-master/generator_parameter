user = 'ubuntu'
app = 'generator_parameter'
deploy_to = "/home/#{user}/apps/#{app}"
rails_root = "#{deploy_to}/current"
pid_file = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file= "#{deploy_to}/shared/unicorn.sock"
log_file = "#{rails_root}/log/unicorn.log"
err_log = "#{rails_root}/log/unicorn_error.log"
old_pid = pid_file + '.oldbin'

timeout 30
worker_processes 4 
listen socket_file, :backlog => 1024
pid pid_file
stderr_path err_log
stdout_path log_file

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end