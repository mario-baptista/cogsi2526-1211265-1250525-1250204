class spring_app {
  package { 'openjdk-17-jdk':
    ensure => installed,
  }

  file { '/opt/spring-app':
    ensure => directory,
    owner  => 'developer',
    group  => 'developer',
    mode   => '0755',
  }

  file { '/etc/systemd/system/spring.service':
    ensure  => file,
    content => template('spring_app/spring.service.erb'),
    mode    => '0644',
  }

  service { 'spring':
    ensure => running,
    enable => true,
    require => File['/etc/systemd/system/spring.service'],
  }
}