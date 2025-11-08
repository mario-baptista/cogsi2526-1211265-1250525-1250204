class h2 {
  package { 'openjdk-17-jdk':
    ensure => installed,
  }

  file { '/opt/h2':
    ensure => directory,
    owner  => 'developer',
    group  => 'developer',
    mode   => '0755',
  }

  file { '/etc/systemd/system/h2.service':
    ensure  => file,
    content => template('h2/h2.service.erb'),
    mode    => '0644',
  }

  service { 'h2':
    ensure => running,
    enable => true,
    require => File['/etc/systemd/system/h2.service'],
  }
}