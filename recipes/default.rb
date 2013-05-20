
package 'munin-node'

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

service 'munin-node' do
  action [:enable, :start]
end
