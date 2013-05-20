
execute 'clean-default-plugins' do
  command "rm -f /etc/munin/plugins/*"
  action :nothing
end

execute 'clean-default-plugin-confd' do
  command "rm -f /etc/munin/plugin-conf.d/*"
  action :nothing
end

package 'munin-node' do
  action :install
  notifies :run, "execute[clean-default-plugins]"
  notifies :run, "execute[clean-default-plugin-confd]"
end

file "/etc/munin/munin-node.conf" do
  content node.generate_munin_node_conf
  mode 00644
  owner 'root'
  group 'root'
  notifies :restart, 'service[munin-node]'
end

node['munin-node']['plugin']['list'].each do |name,target|
  link "/etc/munin/plugins/#{name}" do
    to target
    owner 'root'
    group 'root'
    notifies :restart, 'service[munin-node]'
  end
end

node['munin-node']['plugin']['conf'].each do |section,content|
  # replace illegal/discouraged characters for file names
  name = section.gsub(/[*]/, '')
  content = content.join("\n") if content.kind_of? Array
  file "/etc/munin/plugin-conf.d/#{name}" do
    content "[#{section}]\n#{content}\n"
  end
end

service 'munin-node' do
  action [:enable, :start]
end
