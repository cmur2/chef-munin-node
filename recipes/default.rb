
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
  notifies :run, "execute[clean-default-plugins]", :immediately
  notifies :run, "execute[clean-default-plugin-confd]", :immediately
end

node['munin-node']['additional_packages'].each do |pkg|
  package pkg
end

node['munin-node']['plugin']['downloads'].each do |identifier,source_spec|
  case source_spec['type']
  when 'http'
    remote_file source_spec['dest'] do
      source source_spec['url']
      owner 'root'
      group 'root'
      mode 00755
    end
  when 'git'
    git source_spec['dest'] do
      repository source_spec['repo']
      reference source_spec['ref'] if source_spec['ref']
      user 'root'
      group 'root'
      action :sync
    end
  end
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
    owner 'root'
    group 'root'
    mode 00660 # may contain passwords
    notifies :restart, 'service[munin-node]'
  end
end

service 'munin-node' do
  action [:enable, :start]
end
