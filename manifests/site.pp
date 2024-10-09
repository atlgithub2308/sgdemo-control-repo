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

node 'sgdemodebian2.atl88.online' {
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
  #include sce_windows
  user { 'johndoewin2':
    ensure     => 'present',
    password   => 'P@ssw0rd12345678',
    groups     => ['Administrators'],
  }
}

node 'sgdemorocky2.atl88.online' {
# webserver.pp

# Determine the package and service names based on the operating system
  class webserver {
    case $facts['os']['family'] {
      'Debian': {
        $package_name = 'apache2'
        $service_name = 'apache2'
        $doc_root = '/var/www/html'
      }
      'RedHat': {
        $package_name = 'httpd'
        $service_name = 'httpd'
        $doc_root = '/var/www/html'
      }
      'windows': {
        # Windows configuration: install IIS Web-Server feature
        $package_name = 'Web-Server'
        $service_name = 'w3svc'
        $doc_root = 'C:/inetpub/wwwroot'
      }
      default: {
        fail("Unsupported OS: ${facts['os']['family']}")
      }
    }

    # Ensure the web server package is installed
    package { $package_name:
      ensure => installed,
    }

    # Ensure the web server service is enabled and running
    service { $service_name:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package[$package_name],
    }

    # Ensure the document root exists (for Linux systems)
    if $facts['os']['family'] != 'windows' {
      file { $doc_root:
        ensure => directory,
      }
    }

    # Retrieve HTML content from Hiera and create index.html
    $html_content = lookup('webserver::html_content')

    file { "${doc_root}/index.html":
      ensure  => file,
      content => $html_content,
      mode    => '0644',
      require => Package[$package_name],
    }

    # Windows-specific firewall rule
    if $facts['os']['family'] == 'windows' {
     exec { 'open-port-80':
        command => 'netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80',
        onlyif  => 'netsh advfirewall firewall show rule name="HTTP" | findstr /I "No rules"',
        require => Service[$service_name],
      }
    }

    # Firewall rules for Linux (Debian/RedHat)
    if $facts['os']['family'] != 'windows' {
      exec { 'open-http-port':
        command => '/usr/sbin/ufw allow http',
        unless  => '/usr/sbin/ufw status | grep "80/tcp"',
        require => Service[$service_name],
      }
    }
  }
}
