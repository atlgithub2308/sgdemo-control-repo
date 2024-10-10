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

  file { 'C:/mydir':
    ensure => 'directory',
  }

  file { 'C:/mydir/myfile':
    ensure  => 'file',
    content => 'Welcome to Puppet',
  }
}

node 'sgdemowin2.atl88.online' {
  #include sce_windows
  user { 'johndoewin2':
    ensure     => 'present',
    password   => 'P@ssw0rd12345678',
    groups     => ['Administrators'],
  }

  exec { 'install_chocolatey':
    command   => 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString(''https://chocolatey.org/install.ps1''))',
    provider  => 'powershell',
    unless    => 'choco -v',
    logoutput => true,
  }

  package { 'GoogleChrome':
    ensure   => 'installed',
    provider => 'chocolatey',
    require  => Exec['install_chocolatey'],  # Ensures Chocolatey is installed before installing Chrome
  }
}

node 'sgdemorocky2.atl88.online' {
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
    content => "<html>
                  <head>
                    <meta charset='UTF-8'>
                    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                    <title>Welcome to Rocky Linux Web Server</title>
                    <style>
                      body {
                        font-family: 'Arial', sans-serif;
                        background-color: #f4f4f4;
                        color: #333;
                        margin: 0;
                        padding: 20px;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                      }
                      h1 {
                        color: #007bff;
                        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
                      }
                      p {
                        font-size: 18px;
                      }
                      .card {
                        background: white;
                        border-radius: 8px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        padding: 20px;
                        max-width: 600px;
                        text-align: center;
                        margin-top: 20px;
                      }
                      .footer {
                        margin-top: 20px;
                        font-size: 14px;
                        color: #888;
                      }
                    </style>
                  </head>
                  <body>
                    <h1>Welcome ICIC bank to Puppet World!</h1>
                    <div class='card'>
                      <p>Congratulations! Your web server is up and running smoothly.</p>
                      <p>This server is powered by <strong>Apache</strong> on <strong>Rocky Linux</strong>.</p>
                      <p>Explore and enjoy your new server!</p>
                    </div>
                    <div class='footer'>
                      <p>&copy; 2024 Your Company. All rights reserved.</p>
                    </div>
                  </body>
                </html>",
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
