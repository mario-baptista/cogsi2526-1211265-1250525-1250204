class spring_app::pam_policy {

  file { '/etc/security/pwquality.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF"/L),
minlen=12
minclass=3
maxrepeat=2
dictcheck=1
usercheck=1
maxsequence=3
    | EOF
  }

  augeas { 'pam_unix_password_history':
    context => '/files/etc/pam.d/common-password',
    changes => [
      "set *[module = 'pam_unix.so'] 'password required pam_unix.so remember=5 use_authtok sha512'",
    ],
  }

  augeas { 'pam_tally2_lockout':
    context => '/files/etc/pam.d/common-auth',
    changes => [
      "set *[module = 'pam_tally2.so'] 'auth required pam_tally2.so deny=5 unlock_time=600 onerr=fail audit even_deny_root_account silent'",
    ],
  }

}
