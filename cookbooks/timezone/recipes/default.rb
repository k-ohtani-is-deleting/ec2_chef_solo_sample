#
# Cookbook Name:: timezone 
# Recipe:: default
#
# Copyright 2012, ryuzee 
#
# MIT License 
#
case node[:platform]
when "centos","amazon"
  cmd = "cp -p /usr/share/zoneinfo/Japan /etc/localtime"
  e = execute cmd do
    action :run
  end
end

