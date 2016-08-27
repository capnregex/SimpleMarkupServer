
#!/usr/bin/env puma
# start puma with:
# RAILS_ENV=production bundle exec puma -C ./config/puma.rb

env = ENV['RACK_ENV'] || 'development'
application_path = File.expand_path('../..', __FILE__)
# workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads 0, threads_count

preload_app!

rackup      DefaultRackup

port        ENV['PORT']     || 3000

directory application_path
environment env 
daemonize false

# pidfile "#{application_path}/tmp/pids/puma-#{env}.pid"
# state_path "#{application_path}/tmp/pids/puma-#{env}.state"
# stdout_redirect "#{application_path}/log/puma-#{env}.stdout.log", "#{application_path}/log/puma-#{env}.stderr.log"

# bind "unix://#{application_path}/tmp/sockets/puma.socket"

# activate_control_app "unix://#{application_path}/tmp/sockets/pumactl.socket"

on_worker_boot do
end

