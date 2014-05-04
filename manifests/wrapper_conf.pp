# Set individual property values in wrapper.conf
# *** This type should be considered private to this module ***
define bamboo_agent::wrapper_conf(
  $home       = $title,
  $properties = {},
){

  $path = "${home}/conf/wrapper.conf"

  file { $path:
    owner => $bamboo_agent::user_name,
    group => $bamboo_agent::user_group,
  }
  ->
  r9util::java_properties { $path:
    properties => $properties,
  }

}
