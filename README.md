bamboo_agent
============

[![Build Status](https://travis-ci.org/kayakco/puppet-bamboo_agent.png)](https://travis-ci.org/kayakco/puppet-bamboo_agent)

A Puppet module for managing Bamboo agents.

It can:
  - Install multiple agents side-by-side on a node
  - Manage agent capabilities
  - Set properties in an agent's wrapper.conf
  - Ensure agents are running
  - Ensure agents are started up after a reboot

Examples
--------

Install a single Bamboo agent in /usr/local/bamboo.

    class { 'bamboo_agent':
      server => 'your.bamboo.server.com',
    }

Install two Bamboo agents, named "1" and "2", in /home/bamboo.

    class { 'bamboo_agent':
      server      => 'your.bamboo.server',
      agents      => [1,2],
      install_dir => '/home/bamboo',
    }

Install two Bamboo agents. Give agent 1 extra heap space and give
agent 2 some custom capabilities.

    class { 'bamboo_agent':
      server      => 'your.bamboo.server',
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


See init.pp and agent.pp for more details.
