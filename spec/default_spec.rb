require 'chefspec'

describe 'munin-node::default' do
  let(:chef_runner) do
    cb_path = [Pathname.new(File.join(File.dirname(__FILE__), '..', '..')).cleanpath.to_s, 'spec/support/cookbooks']
    ChefSpec::ChefRunner.new(:cookbook_path => cb_path)
  end

  let(:chef_run) do
    chef_runner.converge 'munin-node::default'
  end
  
  it 'installs munin-node' do
    expect(chef_run).to install_package 'munin-node'
  end
  
  it 'creates munin-node configuration file' do
    expect(chef_run).to create_file_with_content "/etc/munin/munin-node.conf", ''
  end
  
  it 'enables and starts munin-node' do
    expect(chef_run).to start_service 'munin-node'
    expect(chef_run).to set_service_to_start_on_boot 'munin-node'
  end
  
  it 'symlinks enabled plugins' do
    chef_runner.node.set['munin-node']['plugin']['list'] = {
      'if_eth0' => '/usr/share/munin/plugins/if_',
      'custom_path' => '/opt/custom_path'
    }
    chef_run = chef_runner.converge 'munin-node::default'
    expect(chef_run).to create_link "/etc/munin/plugins/if_eth0"
    expect(chef_run).to create_link "/etc/munin/plugins/custom_path"
  end
end
