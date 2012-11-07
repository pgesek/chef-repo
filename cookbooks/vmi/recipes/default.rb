#
# Cookbook Name:: vmi
# Recipe:: default
#
# Copyright 2012, SolDevelo
#
# All rights reserved - Do Not Redistribute
#

template "/var/www/index.html" do
  source "index.html.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/apache2/sites-available/vmi" do
  source "vmi.erb"
end

apache_site "default" do
  enable false
end

apache_site "vmi" do
  enable true
end