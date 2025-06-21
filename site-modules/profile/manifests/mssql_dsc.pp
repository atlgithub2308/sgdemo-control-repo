class profile::mssql_dsc (
  String  $instance_name     = 'MSSQLSERVER',
  Boolean $dynamic_alloc     = false,
  Integer $minservermemory   = 4096,
  Integer $maxservermemory   = 8192,
) {
  exec { 'install_sqlserverdsc_module':
    command => 'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-Module -Name SqlServerDsc -Force -Scope AllUsers"',
    unless  => 'powershell.exe -NoProfile -Command "if (Get-Module -ListAvailable -Name SqlServerDsc) { exit 0 } else { exit 1 }"',
    path    => ['C:/Windows/System32/WindowsPowerShell/v1.0'],
    logoutput => true,
  }
  dsc { 'ConfigureSqlMemory':
    resource_name => 'SqlMemory',
    module        => 'SqlServerDsc',
    properties    => {
      'InstanceName'     => $instance_name,
      'DynamicAlloc'     => $dynamic_alloc,
      'MinServerMemory'  => $minservermemory,
      'MaxServerMemory'  => $maxservermemory,
    },
    require => Exec['install_sqlserverdsc_module'],
  }
}
