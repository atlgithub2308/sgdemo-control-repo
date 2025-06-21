class profile::mssql_dsc (
  String  $instance_name     = 'MSSQLSERVER',
  Boolean $dynamic_alloc     = false,
  Integer $minservermemory   = 4096,
  Integer $maxservermemory   = 8192,
) {

  # Install SqlServerDsc module only if not already present
  exec { 'install_sqlserverdsc_module':
    command => 'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Install-Module -Name SqlServerDsc -Force -Scope AllUsers"',
    unless  => 'powershell.exe -NoProfile -NonInteractive -Command "if (Get-Module -ListAvailable -Name SqlServerDsc) { exit 0 } else { exit 1 }"',
    path    => ['C:/Windows/System32/WindowsPowerShell/v1.0'],
    logoutput => true,
  }

  # Configure SQL Server memory settings using DSC
  dsc_sqlmemory { 'ConfigureSqlMemory':
    dsc_instancename    => $instance_name,
    dsc_dynamicalloc    => $dynamic_alloc,
    dsc_minservermemory => $minservermemory,
    dsc_maxservermemory => $maxservermemory,
    require             => Exec['install_sqlserverdsc_module'],
  }

}
