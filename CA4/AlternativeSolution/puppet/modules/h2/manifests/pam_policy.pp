class h2database::pam_policy {

  $pwquality_settings = {
    'minlen'       => '12',
    'minclass'     => '3',
    'maxrepeat'    => '2',
    'dictcheck'    => '1',
    'usercheck'    => '1',
    'maxsequence'  => '3',
  }

  $pwquality_settings.each |$key, $value| {
    file_line { "pwquality_${key}":
      path  => '/etc/security/pwquality.conf',
      line  => "${key}=${value}",
      match => "^${key}=",
    }
  }

  file_line { 'pam_unix_password_history':
    path  => '/etc/pam.d/common-password',
    line  => 'password required pam_unix.so remember=5 use_authtok sha512',
    match => '^password\s+required\s+pam_unix.so',
  }

  file_line { 'pam_tally2_lockout':
    path  => '/etc/pam.d/common-auth',
    line  => 'auth required pam_tally2.so deny=5 unlock_time=600 onerr=fail audit even_deny_root_account silent',
    match => '^auth required pam_tally2.so',
  }

  include h2database::pam_policy
}
