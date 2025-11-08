class spring_app {

  package { ['openjdk-17-jdk', 'git', 'gradle']:
    ensure => installed,
  }

  file { '/opt/gradle_transformation':
    ensure => directory,
  }

  exec { 'copy_app_source':
    command => 'cp -r /vagrant/gradle_transformation/* /opt/gradle_transformation/',
    creates => '/opt/gradle_transformation/build.gradle',
    require => File['/opt/gradle_transformation'],
    path    => ['/usr/bin', '/bin'],
  }

  file { '/opt/gradle_transformation_ownership':
    path    => '/opt/gradle_transformation',
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0770',
    recurse => true,
    require => [Exec['copy_app_source'], Class['developers']],
  }

  file { '/opt/gradle_transformation/src/main/resources/application.properties':
    ensure  => file,
    content => "spring.datasource.url=jdbc:h2:mem:mydb\nspring.datasource.username=sa\nspring.datasource.password=\nserver.port=8080\n",
    require => Exec['copy_app_source'],
  }

  exec { 'gradle_build':
    command => 'cd /opt/gradle_transformation && ./gradlew build',
    unless  => 'test -f /opt/gradle_transformation/build/libs/GradleProject_Transformation.jar',
    require => [File['/opt/gradle_transformation/src/main/resources/application.properties'], Package['gradle']],
    path    => ['/usr/bin', '/bin'],
  }

  # Systemd service
  file { '/etc/systemd/system/spring.service':
    ensure  => file,
    content => template('spring_app/spring.service.erb'),
  }

  service { 'spring':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/systemd/system/spring.service'],
  }

  # Firewall
  exec { 'ufw_allow_8080':
    command => 'ufw allow 8080/tcp',
    unless  => 'ufw status | grep -q "8080"',
    path    => ['/usr/sbin', '/sbin'],
  }

  # Health check
  exec { 'spring_health_check':
    command => 'curl -f http://localhost:8080/',
    require => Service['spring'],
    path    => ['/usr/bin', '/bin'],
  }

}