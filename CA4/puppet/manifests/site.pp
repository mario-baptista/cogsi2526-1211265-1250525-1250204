node default {
  include developers
  include pam_policy
}

node 'app-vm' {
  include spring_app
}

node 'db-vm' {
  include h2
}