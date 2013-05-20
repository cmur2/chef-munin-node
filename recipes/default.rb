
package 'munin-node'

file "/etc/munin/munin-node.conf" do
  content node.generate_munin_node_conf
  mode 00644
  owner 'root'
  group 'root'
  notifies :restart, 'service[munin-node]'
end

service 'munin-node' do
  action [:enable, :start]
end
