#
# Cookbook Name:: trac 
# Recipe:: default
#
# Copyright 2012, ryuzee 
#
# MIT License 
#
node["trac"]["trac_project_dir"]   = node["trac"]["trac_root_dir"]+"/"+node["trac"]["project_name"]
node["trac"]["svn_repository_dir"] = node["trac"]["svn_repository_root_dir"]+"/"+node["trac"]["project_name"]
case node[:platform]
when "centos","amazon"

  %w{mod_wsgi subversion mod_dav_svn}.each do |package_name|
    package package_name do
      action :install
    end
  end

  %w{Genshi Babel Trac}.each do |package_name|
    easy_install_package package_name do
      action :install
    end
  end

  ## create directory
  dir_list=[
    node["trac"]["trac_root_dir"],
    node["trac"]["svn_repository_root_dir"]
  ]
  dir_list.each do |dir|
    directory dir do
      owner "apache"
      group "apache"
      mode "0755"
      action :create
    end
  end

  ## create svn repository
  e = execute "svnadmin create #{node["trac"]["svn_repository_dir"]}" do
    action :run
    not_if do File.exists?(node["trac"]["svn_repository_dir"]) end
  end

  ## create trac project
  e = execute "trac-admin #{node["trac"]["trac_project_dir"]} initenv #{node["trac"]["project_name"]} sqlite:db/trac.db svn #{node["trac"]["svn_repository_dir"]}" do
    action :run
    not_if do File.exists?("#{node["trac"]["trac_project_dir"]}/conf/trac.ini") end
  end

  ## deploy trac wsgi
  e = execute "trac-admin #{node["trac"]["trac_project_dir"]} deploy /var/www/trac/#{node["trac"]["project_name"]}" do
    action :run
  end

  ## change owner
  dir_list=[node["trac"]["trac_project_dir"], node["trac"]["svn_repository_dir"]]
  dir_list.each do |dir| 
    e = execute "chown -R apache:apache " + dir do
      action :run
    end
  end

  ## deploy apache configuration
  template "/etc/httpd/conf.d/trac_#{node["trac"]["project_name"]}.conf" do
    source "trac.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[httpd]"
  end

  ## deploy mod_dav_svn configuration
  template "/etc/httpd/conf.d/subversion_#{node["trac"]["project_name"]}.conf" do
    source "subversion.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[httpd]"
  end

  ## make password for Trac and SVN
  file node["trac"]["password_file"] do
    owner "apache"
    group "apache"
    mode "0644"
    action :create
    not_if do File.exists?(node["trac"]["password_file"]) end
  end

  e = execute "htpasswd -b #{node["trac"]["password_file"]} #{node["trac"]["admin_account"]} #{node["trac"]["admin_password"]}" do
    action :run
  end

  ## add admin user to trac
  e = execute "trac-admin #{node["trac"]["trac_project_dir"]} permission add #{node["trac"]["admin_account"]} TRAC_ADMIN" do
    action :run
    not_if "trac-admin #{node["trac"]["trac_project_dir"]} permission list | grep #{node["trac"]["admin_account"]}"
  end

  e = execute "easy_install http://trac-hacks.org/svn/accountmanagerplugin/trunk" do
    action :run
    not_if "python -c 'import sys; from pkg_resources import get_distribution; get_distribution(sys.argv[1])' TracAccountManager 2>/dev/null"
  end

  template "#{node["trac"]["trac_root_dir"]}/#{node["trac"]["project_name"]}/conf/trac.ini" do
    source "trac.ini.erb"
    owner "apache"
    group "apache"
    mode "0644"
    not_if "cat #{node["trac"]["trac_root_dir"]}/#{node["trac"]["project_name"]}/conf/trac.ini | grep password_format"
  end

end
