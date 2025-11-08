class developers {
  group { 'developer':
    ensure => present,
  }

  user { 'developer':
    ensure     => present,
    gid        => 'developer',
    home       => '/home/developer',
    managehome => true,
    shell      => '/bin/bash',
  }
}