bamboo_agent
============

[![Build Status](https://travis-ci.org/kayakco/puppet-bamboo_agent.png)](https://travis-ci.org/kayakco/puppet-bamboo_agent)

A Puppet module for managing Bamboo agents.

This module can be used to:
  - Install multiple agents side-by-side on a node
  - Ensure the agents are running
  - Granularly configure agent capabilities
  - Set properties in an agent's wrapper.conf

Examples
--------

Install a single Bamboo agent in /usr/local/bamboo.

```
class { 'bamboo_agent':
  server_host => 'your.bamboo.server',
}
```

Install two Bamboo agents, named "1" and "2", in /home/bamboo.

```
class { 'bamboo_agent':
  server_host => 'your.bamboo.server',
  agents      => [1,2],
  install_dir => '/home/bamboo',
}
```

Install two Bamboo agents. Give agent 1 extra heap space and give
agent 2 some custom capabilities.

```
class { 'bamboo_agent':
  server_host => 'your.bamboo.server',
  agents      => {
    '1' => {
      'wrapper_conf_properties' => {
         'wrapper.java.maxmemory' => '2048',
      }
    },
    '2' => {
      'manage_capabilities' => true,
      'capabilities' => {
         'system.builder.command.Bash' => '/bin/bash',
         'hostname' => $::hostname,
         'os' => $::operatingsystem,
      }
    }
  },
}
```

Ensure that your preferred Java class has been applied before
attempting to install any Bamboo agents.

```
class { 'bamboo_agent':
  server_host     => 'your.bamboo.server',
  java_classname  => 'my_favorite_java',
}
```

See init.pp and agent.pp for more details.
