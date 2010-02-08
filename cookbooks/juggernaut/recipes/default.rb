require 'pp'
#
# Cookbook Name:: juggernaut
# Recipe:: default
#

node[:applications].each do |app_name,data|
  user = node[:users].first

case node[:instance_role]
 when "solo", "app", "app_master"
   template "/etc/monit.d/juggernaut.#{app_name}.monitrc" do
     source "juggernaut.monitrc.erb"
     owner 'root'
     group 'root'
     mode 0644
     variables({
          :app_name => app_name,
          :server_names => node[:members]
     })
   end

   template "/data/#{app_name}/current/config/juggernaut.yml" do
     source "juggernaut.yml.erb"
     owner user[:username]
     group user[:username]
     mode 0744
     variables({
          :app_name => app_name,
          :server_names => node[:members]
     })
   end
   
   template "/data/#{app_name}/current/config/juggernaut_hosts.yml" do
      source "juggernaut_hosts.yml.erb"
      owner user[:username]
      group user[:username]
      mode 0744
      variables({
           :app_name => app_name,
           :server_names => node[:members]
      })
    end
    
    template "/data/#{app_name}/current/config/debug.yml" do
      source "debug.yml.erb"
      owner user[:username]
      group user[:username]
      mode 0744
      variables({
           :node_json => node
      })
    end
 end
end
