class profile::install_postgresql {
  
  package { ['postgresql', 'postgresql-server']:
    ensure => installed,
  }

  exec { 'initdb':
    command => '/usr/bin/postgresql-setup --initdb',
    creates => '/var/lib/pgsql/data/pg_wal',
    require => Package['postgresql-server'],
  }

  service { 'postgresql':
    ensure    => running,
    enable    => true,
    subscribe => Exec['initdb'],
  }

  file_line { 'set max_connections':
    path   => '/var/lib/pgsql/data/postgresql.conf',
    line   => 'max_connections = 150',
    match  => '^max_connections\s*=',
    notify => Service['postgresql'],
  }
}
