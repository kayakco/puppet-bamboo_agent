bamboo_agent
============

[![Build Status](https://travis-ci.org/kayakco/puppet-bamboo_agent.png)](https://travis-ci.org/kayakco/puppet-bamboo_agent)

A Puppet module for managing Bamboo agents.

It can:

- Install multiple agents side-by-side on a node<br>
- Ensure agents are running / started up after a reboot<br>
- Set properties in an agent's wrapper.conf<br>
- Manage agent capabilities<br>


Examples
--------


Install a single Bamboo agent in /usr/local/bamboo.

    class { 'bamboo_agent':
      server => 'your.bamboo.server.com',
    }


Install two Bamboo agents in /home/bamboo.

    class { 'bamboo_agent':
      server      => 'your.bamboo.server',
      agents      => [1,2],
      install_dir => '/home/bamboo',
    }


Advanced Examples
-----------------

Install two Bamboo agents. Give agent 1 extra heap space by setting
the **wrapper.java.maxmemory** property in wrapper.conf.

    class { 'bamboo_agent':
      server => 'your.bamboo.server',
      agents => {
        '1' => {
          'wrapper_conf_properties' => {
             'wrapper.java.maxmemory' => '4096',
          }
         },
        '2' => {},
      }
    }

Install two Bamboo agents. Give the second agent some custom capabilities.

    class { 'bamboo_agent':
      server => 'your.bamboo.server',
      agents => {
        '1' => {},
        '2' => {
          'manage_capabilities' => true,
          'capabilities'        => {
             'system.builder.command.Bash' => '/bin/bash',
             'hostname'                    => $::hostname,
             'os'                          => $::operatingsystem,
          }
        }
      }
    }

Install six bamboo agents. Give them all the hostname and Bash
capabilities from the previous example, as well as a custom capability called
**reserved**. Make **reserved** default to false, but true for agent 2.

    class { 'bamboo_agent':
      server               => 'your.bamboo.server',
      agent_defaults       => {
        'manage_capabilities' => true,
      },
      default_capabilities => {
        'system.builder.command.Bash' => '/bin/bash',
        'hostname'                    => $::hostname,
        'reserved'                    => false,
      },
      agents => {
        '1' => {},
        '2' => {
          'capabilities' => { 'reserved' => true }
        },
        '3' => {},
        '4' => {},
        '5' => {},
        '6' => {},
      }
    }

See init.pp and agent.pp for more details.

Notes
---------

Capabilities are configured using the [bamboo-capabilities.properties file](https://confluence.atlassian.com/display/BAMBOO/Configuring+remote+agent+capabilities+using+bamboo-capabilities.properties)<br>

It is strongly recommended to use [Hiera automatic parameter lookup](http://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup) to configure agents. Below is the final example from above, translated into Hiera configuration format:

    ---
    bamboo_agent::server: your.bamboo.server
    bamboo_agent::agent_defaults:
      manage_capabilities: true
    bamboo_agent::default_capabilities:
      "system.builder.command.Bash": /bin/bash
      hostname: "%{::hostname}"
      reserved: false
    bamboo_agent::agents
      1:
      2:
        capabilities:
          reserved: true
      3:
      4:
      5:
      6:


