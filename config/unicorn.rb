app_name = "generator_parameter"
root = "/home/ubuntu/apps/#{app_name}/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.err.log"
stdout_path "#{root}/log/unicorn.out.log"

listen "/tmp/unicorn.#{app_name}.sock"
worker_processes 2
timeout 30

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end