#
# Cookbook Name:: aws
# Recipe:: default

package "httpd" do
action :install
end
service "httpd" do 
action :start
end

cookbook_file "/var/www/html/index.html" do
source "index.html"
action :create
end

case node[:platform]
when 'debian', 'ubuntu'
  file = '/usr/local/bin/aws'
  cmd = 'apt-get install -y python-pip && pip install awscli'
  completion_file = '/etc/bash_completion.d/aws'
when 'redhat', 'centos', 'fedora', 'amazon', 'scientific'
  file = '/usr/bin/aws'
  cmd = 'yum -y install python-pip && pip install awscli'
end
#Skip to content
#Personal Open source Business Explore
#Sign upSign inPricingBlogSupport
#This repository

#Search

#Watch 7  Star 34  Fork 34 shlomoswidler/awscli

# Code  Issues 0  Pull requests 2  Projects 0  Pulse  Graphs
# Branch: master Find file Copy pathawscli/recipes/default.rb
# 51f4fb7  on Oct 1, 2015
# @damiendurant damiendurant Update default.rb
# 5 contributors @shlomoswidler @rchristensen @house9 @jcoleman @damiendurant
# RawBlameHistory     
# 88 lines (81 sloc)  2.13 KB
# installs Amazon's awscli tools

case node[:platform]
when 'debian', 'ubuntu'
  file = '/usr/local/bin/aws'
  cmd = 'apt-get install -y python-pip && pip install awscli'
  completion_file = '/etc/bash_completion.d/aws'
when 'redhat', 'centos', 'fedora', 'amazon', 'scientific'
  file = '/usr/bin/aws'
  cmd = 'yum -y install python-pip && pip install awscli'
end
case node[:platform]
when 'debian', 'ubuntu'
  file = '/usr/local/bin/aws'
  cmd = 'apt-get install -y vlc'
  completion_file = '/etc/bash_completion.d/aws'
when 'redhat', 'centos', 'fedora', 'amazon', 'scientific'
  file = '/usr/bin/aws'
  cmd = 'yum -y install vlc'
end
r = execute 'install awscli' do
  command cmd
  not_if { ::File.exist?(file) }
  if node[:awscli][:compile_time]
    action :nothing
  end
end
if node[:awscli][:compile_time]
  r.run_action(:run)
end

if node[:awscli][:config_profiles]
  default_user = node[:awscli][:user]
  config_profiles_by_user = node[:awscli][:config_profiles].inject({}) do |hash, (profile_name, config_profile)|
    config_profile = config_profile.dup
    user = config_profile.delete(:user) || default_user
    config_profiles = hash[user] ||= {}
    config_profiles[profile_name] = config_profile
    hash
  end

  config_profiles_by_user.each do |(user, config_profiles)|
    if user == 'root'
      config_file = "/#{user}/.aws/config"
    else
      config_file = "/home/#{user}/.aws/config"
    end

    r = directory ::File.dirname(config_file) do
      recursive true
      owner user
      group user
      mode 00700
      not_if { ::File.exist?(::File.dirname(config_file)) }
      if node[:awscli][:compile_time]
        action :nothing
      end
      if not node[:awscli][:compile_time]
        action :create
      end
    end
    if node[:awscli][:compile_time]
      r.run_action(:create)
    end

    r = template config_file do
      mode 00600
      owner user
      group user
      source 'config.erb'
      variables(
        config_profiles: config_profiles,
      )
      if node[:awscli][:compile_time]
        action :nothing
      end
      if not node[:awscli][:compile_time]
        action :create
      end
    end
    if node[:awscli][:compile_time]
      r.run_action(:create)
    end
  end
end


# Contact GitHub API Training Shop Blog About
# © 2017 GitHub, Inc. Terms Privacy Security Status Help

#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
