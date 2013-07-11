define bamboo_agent::service(
  $home,
  $id    = $title,
){

  $service = "bamboo-agent${id}"
  $script  = "${home}/bin/bamboo-agent.sh"
  $user    = $::bamboo_agent::user_name

  file { "/etc/init.d/${service}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('bamboo_agent/init-script.erb'),
  }
  ->
  service { $service:
    ensure    => running,
    enable    => true,
  }
}
