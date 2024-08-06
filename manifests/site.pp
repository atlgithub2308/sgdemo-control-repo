## site.pp ##

# Disable filebucket by default for all File resources:
File { backup => false }

node default {
  # Check if we've set the role for this node via trusted fact, pp_role.  If yes; include that role directly here.
  if !empty( $trusted['extensions']['pp_role'] ) {
    $role = $trusted['extensions']['pp_role']
    if defined("role::${role}") {
      include "role::${role}"
    }
  }
}

node 'sgdemope.atl88.online' {
  #include sce_linux
}

node 'sgdemorocky1.atl88.online' {
  include sce_linux

  user { 'user1':
    ensure => 'present',
  }

  package { 'telnet':
    ensure => present,
  }
}

node 'sgdemowin1.atl88.online' {
  include sce_windows
}

node 'sgdemowin2.atl88.online' {
  include sce_windows
}
