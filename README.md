# chef-munin-node

[![Build Status](https://travis-ci.org/cmur2/chef-munin-node.png)](https://travis-ci.org/cmur2/chef-munin-node)

## Description

Installs munin-node (the [Munin](http://munin-monitoring.org/) agent) and allows much flexibility and control while configuring it. This cookbook does **not** try to automatically and seamlessly integrate a munin-node into the bigger picture of a company's Munin network and therefore is compatible with chef-solo. Since munin-node can be used standalone with other graphing solutions as well this cookbook makes no assumptions about it's environment.

## Usage

Use `recipe[munin-node::default]` for installing and configuring a munin-node instance.

## Requirements

### Platform

Tested only with munin-node version 1.x on Debian.

Depends on the git cookbook (for plugin cloning).

For supported Chef/Ruby version see [Travis](https://travis-ci.org/cmur2/chef-munin-node).

## Recipes

### default

Installs munin-node, cleans all default plugins and configurations, manages and starts the service and configures it from the attributes found in `node['munin-node']`.

The munin-node.conf is directly generated from the hash `node['munin-node']['conf']` with simple string key-value pairs. If a value is an array of strings it will be converted into multiple lines with the same key and different of the values.

You may install additional packages maybe needed as dependency for some plugins via populating the array `node['munin-node']['additional_packages']` with the package names.

#### plugin list

The `node['munin-node']['plugin']['list']` hash contains simple symbolic name to link file target mappings for symlinking the required plugins in the munin-way.

#### plugin config

The `node['munin-node']['plugin']['conf']` hash is used as skeleton to create one .ini file per entry (aka per plugin) where the key will be the section name and the value (string or array of strings) will be converted into the sections content.

Example snippet:

```json
"conf": {
	"df*": [
		"env.exclude none unknown iso9660 squashfs udf romfs ramfs debugfs tmpfs",
		"env.warning 70",
		"env.critical 90"
	],
	"if_*": "user root"
}
```

#### plugin download

Downloads additional files via HTTP or via cloning a git repository into the maschine to allow easy pulling of new plugins with the same cookbook.

Example snippet:

```json
"downloads": {
  "my_plugin": {
    "type": "http",
    "url": "http://something/my_plugin",
    "dest": "/tmp/my_plugin"
  },
  "my_plugin2": {
    "type": "git",
    "repo": "git://github.com/munin-monitoring/contrib.git",
    "dest": "/tmp/my_plugin_collection"
  }
}
```

## License

chef-munin-node is licensed under the Apache License, Version 2.0. See LICENSE for more information.
