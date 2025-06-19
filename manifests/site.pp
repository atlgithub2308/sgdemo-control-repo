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

  user { 'supermanuser1':
    ensure => 'present',
  }

  file { '/myfile':
    ensure  => 'file',
    content => 'Welcome to Puppet World itg'
  }
}

node 'sgdemorocky1.atl88.online' {
  include sce_linux
  include prometheus
  
  file { '/myfile':
    ensure  => 'file',
    content => 'Welcome to Puppet World TISCO'
  }

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

node 'sgdemodebian2.atl88.online' {
}

node 'sgdemowin1.atl88.online' {
  #include sce_windows

  user { 'johndoewin1':
    ensure     => 'present',
    password   => 'P@ssw0rd12345678',
    groups     => ['Administrators'],
  }

  file { 'C:/mydir':
    ensure => 'directory',
  }

  file { 'C:/mydir/myfile':
    ensure  => 'file',
    content => 'Welcome to Puppet',
  }

  package { 'GoogleChrome':
    ensure   => 'installed',
    provider => 'chocolatey',
  }

  package { 'firefox':
    ensure   => 'installed',
    provider => 'chocolatey',
  }
}

node 'sgdemowin2.atl88.online' {
  #include sce_windows
  include profile::mssql_install
  #include profile::mssql_dsc

  user { 'johndoewin2':
    ensure     => 'present',
    password   => 'P@ssw0rd12345678',
    groups     => ['Administrators'],
  }

  package { 'firefox':
    ensure   => 'installed',
    provider => 'chocolatey',
  }
}

node 'sgdemorocky2.atl88.online' {

  $index_html_content = hiera('web::index_html')
# Ensure the httpd package is installed
  package { 'httpd':
    ensure => installed,
  }

# Ensure the Apache service is enabled and running
  service { 'httpd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['httpd'],
  }

# Ensure the document root directory exists
  file { '/var/www/html':
    ensure => directory,
  }

# Create a more fanciful index.html file
  file { '/var/www/html/index.html':
    ensure  => file,
    content => $index_html_content,
    mode    => '0644',
    require => Package['httpd'],
  }

# Open port 80 for HTTP traffic (if using firewalld)
  exec { 'firewalld-allow-http':
    command => '/usr/bin/firewall-cmd --permanent --add-service=http && /usr/bin/firewall-cmd --reload',
    unless  => '/usr/bin/firewall-cmd --list-all | grep http',
    require => Service['httpd'],
  }
}

node 'sgdemorocky3.atl88.online' {
  include profile::install_postgresql

  file { '/bidvfile':
    ensure  => 'file',
    content => 'Welcome to Puppet BIDV',
  }

  package { ['httpd', 'chrony']:
    ensure => installed,
  }

  service { ['httpd', 'chronyd']:
    ensure  => running,
    enable  => true,
    require => Package['httpd', 'chrony'],
  }

  file_line { 'sshd_maxsessions':
    path   => '/etc/ssh/sshd_config',
    line   => 'MaxSessions 10',
    match  => '^MaxSessions',
    notify => Service['sshd'],
  }

  service { 'sshd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}
