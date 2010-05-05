require 'rubygems'
require 'json'
#
# Cookbook Name:: juggernaut
# Recipe:: default
#

if ['solo', 'app', 'app_master'].include?(node[:instance_role])

  # be sure to replace "app_name" with the name of your application.
  run_for_app("Pludr") do |app_name, data|
  
    execute "change dna.json permissions" do
      command "chmod 644 /etc/chef/dna.json"
    end

    dna = JSON.parse(IO.read('/etc/chef/dna.json'))

    execute "change dna.json permissions" do
      command "chmod 600 /etc/chef/dna.json"
    end

    dna_engineyard = dna['engineyard']
    dna_environment = dna_engineyard['environment']
    dna_instances = dna_environment['instances']

    juggernaut_instances = Array.new

    for instance in dna_instances
      role = instance['role']
      if role == "solo" || role == "app_master" || role == "app"
        juggernaut_instances << instance['public_hostname']
      end
    end
  
    worker_name = "juggernaut"
    
    # The symlink is created in /data/app_name/current/tmp/pids -> /data/app_name/shared/pids, but shared/pids doesn't seem to be?
    directory "/data/#{app_name}/shared/pids" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0755
    end
 
    template "/etc/monit.d/juggernaut.#{app_name}.monitrc" do
      source "juggernaut.monitrc.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
        :app_name => app_name,
        :user => node[:owner_name],
        :worker_name => worker_name,
        :framework_env => node[:environment][:framework_env]
      })
    end
    
    template "/data/#{app_name}/shared/config/juggernaut_hosts.yml" do
      source "juggernaut_hosts.yml.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      variables({
        :hosts => juggernaut_instances
      })
    end
    
    #template "/data/#{app_name}/shared/config/juggernaut.yml" do
    #  source "juggernaut.yml.erb"
    #  owner node[:owner_name]
    #  group node[:owner_name]
    #  mode 0644
    #  variables({
    #    :hosts => juggernaut_instances
    #  })
    #end
    
    bash "monit-reload-restart" do
       user "root"
       code "pkill -9 monit && monit"
    end
      
  end
  
 
end