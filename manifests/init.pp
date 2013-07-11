# A module for installing multiple Bamboo agents on a node. Uses
# Puppet service type to ensure that agents are running.
#
# Can be used to:
#   * install agents
#   * set properties in a agent's wrapper.conf
#   * granularly configure agent capabilities
#   * give agents local tmp directories inside home dir. (Useful
#     if you are doing large subversion checkouts on a machine with
#     limited space in / or /tmp filesystems)
#
class bamboo_agent(
  $server_host,
  $server_port    = 8085,

  $agents         = [1],
  $agent_defaults = {},
  $install_dir    = '/usr/local/bamboo',

  $manage_user    = true,
  $user_name      = 'bamboo',
  $user_options   = {
    'shell' => '/bin/bash',
  },

  $java_classname = undef,
  $java_command   = 'java',

  # Default capabilities for the agents on this node.
  # Only matters if capabilities are configured to be managed.
  $default_capabilities = {},

  # Example set of default capabilities (can be overridden per agent).
  # {
  #   'dedicated'                   => false,
  #   'hostname'                    => $::hostname,
  #   'agentid'                     => '!ID!',
  #   'agentkey'                    => "${::hostname}-!ID!",
  #   'system.builder.command.Bash' => '/bin/bash',
  # }
  # (!ID! is expanded to match the agent's resource title / ID parameter)
  #
){

  $user_group = pick($user_options['group'],$user_name)
  if $manage_user {
    create_resources('r9util::system_user',
                      { "${user_name}" => $user_options })
  }

  file { $install_dir:
    ensure => directory,
    owner  => $user_name,
    group  => $user_group,
    mode   => '0755',
  }

  $server_url    = "http://${server_host}:${server_port}"
  $installer_jar = "${install_dir}/bamboo-agent-installer.jar"

  r9util::download { 'bamboo-agent-installer':
    url  => "${server_url}/agentServer/agentInstaller",
    path => $installer_jar,
  }
  ->
  file { $installer_jar:
    mode  => '0644',
    owner => $user_name,
    group => $user_group,
  }

  if $java_classname != undef {
    include $java_classname
    Bamboo_Agent::Agent <||> {
      require => Class[$java_classname]
    }
  }

  $agent_list = normalize_agents_arg($agents)
  create_resources(bamboo_agent::agent,
                    $agent_list,
                    $agent_defaults)
}
