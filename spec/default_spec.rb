require 'chefspec'
begin require 'chefspec/deprecations'; rescue LoadError; end

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

  it 'creates plugin-conf.d files for every plugin to configure' do
    chef_runner.node.set['munin-node']['plugin']['conf'] = {
      'if_*' => 'user root',
      'df*' => [
        'env.exclude none unknown iso9660 squashfs udf romfs ramfs debugfs',
        'env.warning 92',
        'env.critical 98'
      ]
    }
    chef_run = chef_runner.converge 'munin-node::default'
    expect(chef_run).to create_file_with_content "/etc/munin/plugin-conf.d/if_", "[if_*]\nuser root\n"
    expect(chef_run).to create_file_with_content "/etc/munin/plugin-conf.d/df", "[df*]\nenv.exclude none unknown iso9660 squashfs udf romfs ramfs debugfs\nenv.warning 92\nenv.critical 98\n"
  end

  it 'installs additional user-defined packages' do
    chef_runner.node.set['munin-node']['additional_packages'] = [
      'foo', 'bar'
    ]
    chef_run = chef_runner.converge 'munin-node::default'
    expect(chef_run).to install_package 'foo'
    expect(chef_run).to install_package 'bar'
  end

  it 'downloads plugins via http' do
    chef_runner.node.set['munin-node']['plugin']['downloads'] = {
      'my_plugin' => {
        'type' => 'http',
        'url' => 'http://example.org/my_plugin',
        'dest' => '/tmp/my_plugin'
      }
    }
    chef_run = chef_runner.converge 'munin-node::default'
    expect(chef_run).to create_remote_file('/tmp/my_plugin').with(:source => 'http://example.org/my_plugin')
  end

  it 'downloads plugins via git' do
    chef_runner.node.set['munin-node']['plugin']['downloads'] = {
      'my_plugin' => {
        'type' => 'git',
        'repo' => 'git://github.com/munin-monitoring/contrib.git',
        'dest' => '/tmp/my_plugin_collection',
        'ref' => 'my_branch'
      }
    }
    chef_run = chef_runner.converge 'munin-node::default'

    pending 'Cannot test git clones'
  end
  
  it 'downloads plugins via package' do
    chef_runner.node.set['munin-node']['plugin']['downloads'] = {
      'my_plugin' => {
        'type' => 'package',
        'name' => 'my-plugin-package'
      }
    }
    chef_run = chef_runner.converge 'munin-node::default'
    expect(chef_run).to install_package 'my-plugin-package'
  end
end
