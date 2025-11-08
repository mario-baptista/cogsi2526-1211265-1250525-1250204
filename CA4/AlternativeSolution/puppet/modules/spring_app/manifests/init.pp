class spring_app {
    package { 'openjdk-21-jdk':
    ensure => installed,
    }

  file { '/opt/spring-app':
    ensure => directory,
    owner  => 'developer',
    group  => 'developer',
    mode   => '0755',
  }

  file { '/opt/spring-app/app.jar':
    ensure => file,
    source => '/vagrant/gradle_transformation/build/libs/GradleProject_Transformation.jar',
    owner  => 'developer',
    group  => 'developer',
    mode   => '0755',
    require => File['/opt/spring-app'],
  }

  file { '/etc/systemd/system/spring.service':
    ensure  => file,
    content => template('spring_app/spring.service.erb'),
    mode    => '0644',
  }

  exec { 'reload-systemd':
    command => '/bin/systemctl daemon-reload',
    refreshonly => true,
    subscribe => File['/etc/systemd/system/spring.service'],
  }

    service { 'spring':
    ensure => running,
    enable => true,
    require => [Package['openjdk-21-jdk'], File['/opt/spring-app/app.jar']],
    }
}
