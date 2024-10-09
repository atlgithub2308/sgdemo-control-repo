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
  class { 'puppet_data_connector':
    dropzone => '/opt/puppetlabs/puppet/puppet_data_connector',
  }
}

node 'sgdemorocky1.atl88.online' {
  include sce_linux
  include prometheus
  user { 'user1':
    ensure => 'present',
  }

  package { 'telnet':
    ensure => present,
  }
}

node 'sgdemodebian1.atl88.online' {
  class { 'prometheus::node_exporter':
    version            => '1.8.2',
    collectors_disable => ['loadavg', 'mdadm'],
  }
}

node 'sgdemowin1.atl88.online' {
  #include sce_windows

  user { 'johndoewin1':
    ensure     => 'present',
    password   => 'P@ssw0rd12345678',
    groups     => ['Administrators'],
  }
}

node 'sgdemowin2.atl88.online' {
  include sce_windows
  user { 'johndoewin2':
    ensure     => 'present',
    password   => 'P@ssw0rd12345678',
    groups     => ['Administrators'],
  }
}
