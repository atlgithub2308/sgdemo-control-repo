class profile::mssql_dsc (
  String  $instance_name     = 'MSSQLSERVER',
  Boolean $dynamic_alloc     = false,
  Integer $minservermemory   = 4096,
  Integer $maxservermemory   = 8192,
) {

  # Ensure the SqlServerDsc PowerShell module is installed from PSGallery
  dsc_psmodule { 'SqlServerDsc':
    ensure => 'present',
  }

  # Configure SQL Server memory settings via DSC resource SqlMemory
  dsc_sqlmemory { 'ConfigureSqlMemory':
    dsc_instancename    => $instance_name,
    dsc_dynamicalloc    => $dynamic_alloc,
    dsc_minservermemory => $minservermemory,
    dsc_maxservermemory => $maxservermemory,
    require             => Dsc_psmodule['SqlServerDsc'],
  }
}
