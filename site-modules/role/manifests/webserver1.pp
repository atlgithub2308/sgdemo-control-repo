class webserver {
  # Define variables to accommodate different OS families
  case $facts['os']['family'] {
    'RedHat', 'Rocky': {
      $package_name = 'httpd'
      $service_name = 'httpd'
      $docroot      = '/var/www/html'
    }
    'Debian': {
      $package_name = 'apache2'
      $service_name = 'apache2'
      $docroot      = '/var/www/html'
    }
    'windows': {
      $package_name = 'IIS'
      $service_name = 'W3SVC'
      $docroot      = 'C:/inetpub/wwwroot'
    }
    default: {
      fail("Unsupported operating system: ${facts['os']['name']}")
    }
  }

  # Install the webserver package
  package { $package_name:
    ensure => installed,
  }

  # Ensure the service is running
  service { $service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }

  # Create the index.html file from Hiera
  file { "${docroot}/index.html":
    ensure  => file,
    content => hiera('webserver_html_content', '<html><body><h1>Default Content</h1></body></html>'),
    require => Package[$package_name],
  }
}
