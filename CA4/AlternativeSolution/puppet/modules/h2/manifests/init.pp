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

exec { 'download-h2':
    command => '/usr/bin/wget -O /opt/h2/h2.jar https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar',
    creates => '/opt/h2/h2.jar',
    path    => ['/usr/bin', '/bin'],
    require => Package['openjdk-17-jdk'],
}


file { '/etc/systemd/system/h2.service':
    ensure  => file,
    content => template('h2/h2.service.erb'),
    mode    => '0644',
}

service { 'h2':
    ensure => running,
    enable => true,
    require => [Exec['download-h2'], File['/etc/systemd/system/h2.service']],
}
}
