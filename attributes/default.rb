
default['munin-node']['conf'] = {
  'log_level' => 4,
  'log_file' => '/var/log/munin/munin-node.log',
  'pid_file' => '/var/run/munin/munin-node.pid',
  'background' => 1,
  'setsid' => 1,
  'user' => 'root',
  'group' => 'root',
  'ignore_file' => [
    '~$',
    'DEADJOE$',
    '\.bak$',
    '%$',
    '\.dpkg-(tmp|new|old|dist)$',
    '\.rpm(save|new)$',
    '\.pod$'
  ],
  'allow' => '^127\.0\.0\.1$',
  'host' => '*',
  'port' => 4949
}

default['munin-node']['plugin']['list'] = {}

default['munin-node']['plugin']['conf'] = {}

default['munin-node']['plugin']['downloads'] = {}
