require_recipe "ntdrush"

# clean /var/www/html
directory "/var/www/html/drupal" do
    action :delete
    recursive true
end

# Set up keys
execute "cp /tmp/keys/id_rsa $HOME/.ssh/id_rsa" do
    not_if { File.exist?("$HOME/.ssh/id_rsa") }
end
execute "cp /tmp/keys/id_rsa.pub $HOME/.ssh/id_rsa.pub" do
    not_if { File.exist?("$HOME/.ssh/id_rsa.pub") }
end
execute "cp /tmp/keys/known_hosts $HOME/.ssh/known_hosts" do
    not_if { File.exist?("$HOME/.ssh/known_hosts") }
end

dburl = node['drupal']['dburl']
adminacc = node["drupal"]["adminname"]
adminpass = node["drupal"]["adminpass"]
sqlrootpass = node["mysql"]["server_root_password"]
manifest = node["drupal"]["manifest"]
workingcopy = node["drupal"]["workingcopy"]


package "php-apc" do
      action :install
end

package "php5-gd" do
      action :install
end

package "php5-curl" do
      action :install
end

package "php5-mysql" do
      action :install
end

package "php5-imagick" do
      action :install
end

package "php5-memcache" do
      action :install
end

package "php5-memcached" do
      action :install
end

package "ruby-compass" do
      action :install
end

package "haproxy" do
      action :install
end

package "php5-xdebug" do
      action :install
end

# run ntdc
if workingcopy
    bash "working_drupal" do
        code <<-EOH
            ntdc -v -w -u #{dburl} -n #{adminacc} -p #{adminpass} -m root:#{sqlrootpass} -t /var/www/html/drupal #{manifest} > /var/log/drupal.log
            echo ntdc -v -w -u #{dburl} -n #{adminacc} -p #{adminpass} -m root:#{sqlrootpass} -t /var/www/html/drupal #{manifest} > /var/tmp/cmd
        EOH
        action :run
    end
else
    bash "deploy_drupal" do
        code <<-EOH
            ntdc -v -u #{dburl} -n #{adminacc} -p #{adminpass} -m root:#{sqlrootpass} -t /var/www/html/drupal #{manifest} > /var/log/drupal.log
            echo ntdc -v -u #{dburl} -n #{adminacc} -p #{adminpass} -m root:#{sqlrootpass} -t /var/www/html/drupal #{manifest} > /var/tmp/cmd
        EOH
        action :run
    end
end

# reset permissions
bash "working_drupal" do
    code <<-EOH
        ntresetperms -y #{node["drupal"]["user"]} #{node["drupal"]["group"]} #{node["apache"]["user"]} #{node["apache"]["group"]} -p /var/www/html/drupal
    EOH
    action :run
end

directory "/tmp" do
    owner "root"
    group "root"
    mode 01777
    action :create
end

web_app 'drupal' do
    template 'site.conf.erb'
end

template '/etc/haproxy/haproxy.cfg' do
    source "haproxy.cfg.erb"
    action :create
end

template '/etc/default/haproxy' do
    source "haproxy.erb"
    action :create
end

template '/etc/php5/mods-available/xdebug.ini' do
    source "xdebug.ini.erb"
    action :create
end

apache_site "default" do
    enable false
end
