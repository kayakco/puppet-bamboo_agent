bamboo_agent
============

[![Build Status](https://travis-ci.org/kayakco/puppet-bamboo_agent.png)](https://travis-ci.org/kayakco/puppet-bamboo_agent)

A Puppet module for managing Bamboo agents.

This module can be used to:
  * Install multiple agents side-by-side on a node
  * Ensure agents are running
  * Granularly configure agent capabilities
  * Set properties in an agent's wrapper.conf
  * Give agents private tmp directories inside their home directories. (Useful if you are doing large Subversion checkouts on a machine with limited space in / or /tmp)

See init.pp and agent.pp for examples.
