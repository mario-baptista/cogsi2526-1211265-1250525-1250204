class developers {

  group { 'developers':
    ensure => present,
  }

  user { 'devuser':
    ensure     => present,
    gid        => 'developers',
    groups     => ['developers'],
    shell      => '/bin/bash',
    home       => '/home/devuser',
    managehome => true,
  }

}