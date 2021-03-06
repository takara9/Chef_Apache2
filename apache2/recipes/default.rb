#
# Cookbook Name:: apache2
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#
port = 8080

case node['platform_family']
  when 'debian'
    package_name  = 'apache2'
    service_name  = 'apache2'
    document_root = '/var/www'
    config_file   = '/etc/apache2/ports.conf'
    config_file2  = '/etc/apache2/sites-available/default'
    template_config = 'ports.conf.erb'
    template_config2 = 'default.erb'
  when 'rhel'
    package_name  = 'httpd'
    service_name  = 'httpd'
    document_root = '/var/www/html'
    config_file   = '/etc/httpd/conf/httpd.conf'
    template_config = 'httpd.conf.erb'
end

#
package package_name do
  action :install
end

# 
template config_file do
  owner 'root'
  mode  0644
  source template_config
  variables({
    :port => port
  })
  notifies :restart, "service[#{service_name}]"
end

#
if platform_family? 'debian'
  template config_file2 do
    owner 'root'
    mode  0644
    source template_config2
    variables({
      :port => port
    })
    notifies :restart, "service[#{service_name}]"
  end
end

#
service service_name do
  action [ :enable, :start ]
end

cookbook_file "#{document_root}/index.html" do
  source 'index.html'
  mode '0644'
end


#
case node['platform_family']
  when 'rhel'
    bash 'open port in rhel' do
    code <<-EOC
    iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport #{port} -j ACCEPT
    service iptables save
    EOC
    end
  when 'debian'
    bash 'open port in debian' do
    code <<-EOC
    ufw allow #{port}/tcp
    EOC
    end
end

