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

  user { 'user1':
    ensure => 'present',
  }

  user { 'user2':
    ensure => 'present',
  }
  file { '/myfile':
    ensure  => 'file',
    content => 'Welcome to Puppet World itg',
  }
}

node 'sgdemorocky1.atl88.online' {
  #include sce_linux
  include prometheus

  file { '/myfile':
    ensure  => 'file',
    content => 'new content',
  }

  user { 'user1':
    ensure => 'present',
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
    ensure   => 'present',
    password => lookup('windows::johndoewin1_password'),
    groups   => ['Administrators'],
  }

  file { 'C:/mydir':
    ensure => 'directory',
  }

  file { 'C:/mydir/myfile':
    ensure  => 'file',
    content => 'This is my new content',
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
  include profile::mssql_dsc

  file { 'C:/ProgramData/PuppetLabs/facter/facts.d/location.txt':
    ensure  => file,
    content => "location=sydney\n",
  }

  user { 'johndoewin2':
    ensure   => 'present',
    password => lookup('windows::johndoewin2_password'),
    groups   => ['Administrators'],
  }

  package { 'firefox':
    ensure   => 'present',
    provider => 'chocolatey',
  }
}

node 'sgdemowin3.atl88.online' {
  # wsus01.atl88.online does not exist, so Windows Update and Defender signatures
  # were failing. Purge the WSUS policy values so win3 uses Microsoft Update again.
  class { 'wsus_client':
    purge_values => true,
  }

  include sce_windows

  # The built-in Administrator can be exempt from account lockout, and it was
  # the most-guessed name (about 29,500 of 34,377 attempts in win3's last 6 hours).
  # sce_windows 2.2.1 maps CIS 1.2.3 (Allow Administrator account lockout) to the
  # reset-counter setting instead, so disable the account, as it already is on win2.
  dsc_securityoption { 'Disable built-in Administrator':
    dsc_name                                  => 'Disable built-in Administrator',
    dsc_accounts_administrator_account_status => 'Disabled',
  }
}

node 'sgdemorocky2.atl88.online' {
  include profile::pvs_rescan_on_boot

  $index_html_content = hiera('web::index_html')

  package { 'httpd':
    ensure => installed,
  }

  package { 'wget':
    ensure => installed,
  }

  service { 'httpd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['httpd'],
  }

  file { '/var/www/html':
    ensure => directory,
  }

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
  include sce_linux

  file { '/justafile':
    ensure  => 'file',
    content => 'Welcom123456',
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
    line   => 'MaxSessions 5',
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
