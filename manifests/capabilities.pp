# Configure bamboo agent capabilities
# *** This type should be considered private to this module ***
define bamboo_agent::capabilities(
  $home,
  $id               = $title,
  $capabilities     = {},
  $expand_id_macros = false,
){

  $final_capabilities = $expand_id_macros ? {
    true    => expand_id_macros($capabilities,$id),
    default => $capabilities,
  }

  file { "${home}/bin/bamboo-capabilities.properties":
    ensure  => file,
    mode    => '0644',
    owner   => 'bamboo',
    group   => 'bamboo',
    content => template('bamboo_agent/bamboo-capabilities.properties.erb')
  }
}
