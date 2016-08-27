
require 'etc'

namespace :install do

  lib_path = File.expand_path('../..', __FILE__)
  site_path = File.expand_path('..', lib_path)
  server_name = File.basename(site_path)
  stat = File.stat(site_path)
  user = Etc.getpwuid(stat.uid).name
  group = Etc.getgrgid(stat.gid).name
  upstream = server_name.gsub('.','_')
  template_path = File.join(lib_path,'templates','install')
  systemd_name = "puma_" + server_name 
  service_name = systemd_name + '.service'
  service_file = File.join('/etc','systemd','system',service_name)
  socket_name = systemd_name + '.socket'
  socket_file = File.join('/etc','systemd','system',socket_name)
  socket_path = File.join(site_path,'tmp','sockets','puma.socket')

  def echosystem *args
    puts args.join(' ')
    system *args
  end

  desc "install nginx site file"
  task nginx: :environment do
    filename = File.join(template_path,'nginx_site')
    erb = ERB.new(File.read(filename))
    erb.filename = filename

    tmp_file = File.join(site_path,'tmp',server_name)
    site_available = File.join('/etc','nginx','sites-available',server_name)
    site_enabled = File.join('/etc','nginx','sites-enabled',server_name)

    result = erb.result(binding)
    open(tmp_file,'w',0644) do |f|
      f.puts result
    end

    echosystem "sudo cp #{tmp_file} #{site_available}"
    echosystem "sudo chown root:root #{site_available}"
    echosystem "sudo ln -fs #{site_available} #{site_enabled}"
    FileUtils.rm(tmp_file)
  end

  desc "install systemd service file"
  task service: :environment do
    filename = File.join(template_path,'puma.service')
    erb = ERB.new(File.read(filename))
    erb.filename = filename

    tmp_file = File.join(site_path,'tmp', service_name )

    result = erb.result(binding)
    open(tmp_file,'w',0644) do |f|
      f.puts result
    end

    echosystem "sudo cp #{tmp_file} #{service_file}"
    echosystem "sudo chown root:root #{service_file}"
    FileUtils.rm(tmp_file)
  end

  desc "install systemd socket file"
  task socket: :environment do
    filename = File.join(template_path,'puma.socket')
    erb = ERB.new(File.read(filename))
    erb.filename = filename

    tmp_file = File.join(site_path,'tmp', socket_name )

    result = erb.result(binding)
    open(tmp_file,'w',0644) do |f|
      f.puts result
    end

    echosystem "sudo cp #{tmp_file} #{socket_file}"
    echosystem "sudo chown root:root #{socket_file}"
    FileUtils.rm(tmp_file)
  end

  desc "systemd daemon-reload restart nginx and #{socket_name}"
  task reload: [] do 
    echosystem "sudo systemctl daemon-reload"
    echosystem "sudo systemctl restart nginx"
    echosystem "sudo systemctl restart #{socket_name}"
  end

  desc "systemd restart #{systemd_name}"
  task restart: [] do 
    echosystem "sudo systemctl stop #{service_name}"
    echosystem "sudo systemctl restart #{socket_name}"
  end

  desc "systemd restart #{systemd_name}"
  task stop: [] do 
    echosystem "sudo systemctl stop #{socket_name}"
    echosystem "sudo systemctl stop #{service_name}"
  end

  desc "systemd restart #{systemd_name}"
  task status: [] do 
    echosystem "sudo systemctl status #{socket_name}"
    echosystem "sudo systemctl status #{service_name}"
  end

  desc "systemd service and socket files"
  task systemd: [:environment, :service, :socket]

  task all: [:nginx, :systemd, :reload]

end

desc "Install everything"
task install: 'install:all'

