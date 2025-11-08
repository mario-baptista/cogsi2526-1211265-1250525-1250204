class pam_policy {

  package { 'libpam-pwquality':
    ensure => installed,
  }

  file { '/etc/security/pwquality.conf':
    ensure  => file,
    content => "minlen=12\nminclass=3\nmaxrepeat=2\ndictcheck=1\nusercheck=1\nmaxsequence=3\n",
    require => Package['libpam-pwquality'],
  }

  exec { 'pam_unix_remember':
    command => "sed -i 's/^password required pam_unix.so/password required pam_unix.so remember=5 use_authtok sha512/' /etc/pam.d/common-password",
    unless  => "grep -q 'remember=5' /etc/pam.d/common-password",
    path    => ['/usr/bin', '/bin'],
  }

  exec { 'pam_tally2':
    command => "sed -i '/pam_unix.so/a auth required pam_tally2.so deny=5 unlock_time=600 onerr=fail audit even_deny_root_account silent' /etc/pam.d/common-auth",
    unless  => "grep -q 'pam_tally2.so' /etc/pam.d/common-auth",
    path    => ['/usr/bin', '/bin'],
  }

}