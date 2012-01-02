#
# Cookbook Name:: apache_mysql_php
# Recipe:: default
#
# Copyright 2012, ryuzee 
#
# MIT License 
#

case node[:platform]
when "centos","amazon"

  %w{httpd}.each do |package_name|
    package package_name do
      action :install
    end
  end

  ## register service (run level 2345 ) and restart 
  service "httpd" do
    supports :restart => true, :reload => true, :status => true
    action [:enable]
    not_if do File.exists?("/var/run/httpd.pid") end
  end

  %w{mysql-server}.each do |package_name|
    yum_package package_name do
      action :install
    end
  end

  service "mysqld" do
    action [:enable, :restart]
    supports :status => true, :start => true, :stop => true, :restart => true
    not_if do File.exists?("/var/run/mysqld/mysqld.pid") end
  end

  execute "set_mysql_root_password" do
    command "/usr/bin/mysqladmin -u root password \"#{node['mysql']['root_password']}\""
    action :run
    only_if "/usr/bin/mysql -u root -e 'show databases;'"
  end

  %w{php php-common php-cli php-devel php-mbstring php-pdo php-mysql php-xml php-pear}.each do |package_name|
    yum_package package_name do
      action :install
    end
  end 

  template "/etc/php.ini" do
    source "php.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[httpd]"
  end

  ## if not file exists, create new one
  template "/var/www/html/index.php" do
    source "index.php.erb"
    owner node["apache"]["www_user"]
    group node["apache"]["www_group"]
    mode  "0644"
    not_if do File.exists?("/var/www/html/index.php") end
  end

end
