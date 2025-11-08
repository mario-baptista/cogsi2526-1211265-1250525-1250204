class h2 {

  package { ['openjdk-17-jdk', 'ufw', 'wget']:
    ensure => installed,
  }

  file { '/opt/h2':
    ensure => directory,
  }

  exec { 'download_h2':
    command => 'wget -O /opt/h2/h2.jar https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar',
    creates => '/opt/h2/h2.jar',
    require => File['/opt/h2'],
    path    => ['/usr/bin', '/bin'],
  }

  file { '/opt/h2_ownership':
    path    => '/opt/h2',
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0770',
    recurse => true,
    require => [Exec['download_h2'], Class['developers']],
  }

  # Firewall
  exec { 'ufw_enable':
    command => 'ufw --force enable',
    unless  => 'ufw status | grep -q "Status: active"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_deny_incoming':
    command => 'ufw default deny incoming',
    unless  => 'ufw status | grep -q "Default: deny (incoming)"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_allow_ssh':
    command => 'ufw allow 22/tcp',
    unless  => 'ufw status | grep -q "22/tcp"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_allow_9092':
    command => 'ufw allow from 192.168.56.11 to any port 9092 proto tcp',
    unless  => 'ufw status | grep -q "9092"',
    path    => ['/usr/sbin', '/sbin'],
  }

  exec { 'ufw_allow_outgoing':
    command => 'ufw default allow outgoing',
    unless  => 'ufw status | grep -q "Default: allow (outgoing)"',
    path    => ['/usr/sbin', '/sbin'],
  }

  # Systemd service
  file { '/etc/systemd/system/h2.service':
    ensure  => file,
    content => template('h2/h2.service.erb'),
  }

  service { 'h2':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/systemd/system/h2.service'],
  }

  # Health check
  exec { 'h2_health_check':
    command => 'ss -tulpn | grep :9092',
    unless  => 'ss -tulpn | grep -q :9092',
    require => Service['h2'],
    path    => ['/usr/bin', '/bin'],
  }

}