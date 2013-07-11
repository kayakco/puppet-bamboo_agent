define bamboo_agent::agent(
  $id           = $title,
  $home         = "${bamboo_agent::install_dir}/agent${title}-home",
  $wrapper_conf_properties = {},
  $manage_capabilities     = false,
  $capabilities            = {},
  $expand_id_macros        = true,  # Replace any instances of "!ID!"
                                    # in capabilities with $id
  $private_tmp_dir         = false,
){

  validate_hash($wrapper_conf_properties)
  validate_hash($capabilities)

  if $id !~ /\A[-\w]+\z/ {
    fail("${id} is not a valid agent id")
  }

  file { $home:
    ensure => directory,
    owner  => $bamboo_agent::user_name,
    group  => $bamboo_agent::user_group,
    mode   => '0755',
  }
  ->
  bamboo_agent::install { "install-agent-${id}":
    id     => $id,
    home   => $home,
  }
  $install = Bamboo_Agent::Install["install-agent-${id}"]

  bamboo_agent::service { $id:
    home    => $home,
    require => $install,
  }
  $service = Bamboo_Agent::Service[$id]

  if $manage_capabilities {
    bamboo_agent::capabilities { $id:
      home             => $home,
      capabilities     => merge($bamboo_agent::default_capabilities,
                                $capabilities),
      expand_id_macros => $expand_id_macros,
      before           => $service,
      require          => $install,
    }
  }

  if $private_tmp_dir {
    $agent_tmp    = "${home}/.agent_tmp"
    $tmp_dir_props = {
      'set.TMP'                   => $agent_tmp,
      'wrapper.java.additional.3' => "-Djava.io.tmpdir=${agent_tmp}",
    }

#    notice("Adding properties to wrapper.conf: ${tmp_dir_props}")

    bamboo_agent::private_tmp { $agent_tmp: require => $install }
  }else{
    $tmp_dir_props = {}
  }

  bamboo_agent::wrapper_conf { $id:
    home       => $home,
    properties => merge($tmp_dir_props,
                        $wrapper_conf_properties),
    before     => $service,
    require    => $install,
  }


}
