class profile::mssql_install {
  # Define parameters for flexibility
  $mssql_version           = '2022'
  $sql_server_install_url  = 'https://go.microsoft.com/fwlink/?linkid=866658'
  $sql_server_config_url   = 'C:\Installers\ConfigurationFile.ini'
  $mssql_client_gui_url    = 'https://aka.ms/ssmsfullsetup'
  $sql_server_install_path = 'C:\Installers\SQLServer2022.exe'
  $sql_server_config_file  = 'C:\Installers\ConfigurationFile.ini'
  $mssql_client_gui_path   = 'C:\Installers\SQLManagementStudio.exe'

  # Ensure the installation directory exists
  file { 'C:\Installers':
    ensure => 'directory',
  }

  # Create the SQL Server configuration file with default values
  file { $sql_server_config_file:
    ensure  => 'file',
    content => @("CONFIGFILE")
      SQL Server Configuration File
      [OPTIONS]
      ACTION="Install"
      ENU="True"
      FEATURES="SQLENGINE"
      INSTANCENAME="MSSQLSERVER"
      SQLSVCACCOUNT="NT AUTHORITY\\SYSTEM"
      AGTSVCACCOUNT="NT AUTHORITY\\SYSTEM"
      SQLSYSADMINACCOUNTS="BUILTIN\\ADMINISTRATORS"
      SECURITYMODE="SQL"
      SAPWD="YourStrong!Password"
      IACCEPTSQLSERVERLICENSETERMS="True"
    CONFIGFILE
    ,
    require => File['C:\Installers'],
  }

  # Download SQL Server installer
  exec { 'Download SQL Server Installer':
    command   => "Invoke-WebRequest -Uri ${sql_server_install_url} -OutFile $sql_server_install_path",
    provider  => powershell,
    logoutput => true,
    creates   => $sql_server_install_path,
    require   => File['C:\Installers'],
  }

  # Download SQL Management Studio installer
  exec { 'Download SQL Management Studio':
    command   => "Invoke-WebRequest -Uri ${mssql_client_gui_url} -OutFile $mssql_client_gui_path",
    provider  => powershell,
    logoutput => true,
    creates   => $mssql_client_gui_path,
    require   => File['C:\Installers'],
  }

  # Install MSSQL Server only if it's not already installed
  exec { 'Install SQL Server':
    command   => "${sql_server_install_path} /ConfigurationFile=${sql_server_config_file}",
    provider  => powershell,
    logoutput => true,
    unless    => "if ((Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL').MSSQLSERVER) { exit 0 } else { exit 1 }",
    require   => [Exec['Download SQL Server Installer'], File[$sql_server_config_file]],
  }

  # Install MSSQL Management Studio (Client GUI)
  exec { 'Install SQL Management Studio':
    command   => "${mssql_client_gui_path} /quiet /norestart",
    provider  => powershell,
    logoutput => true,
    unless    => "Get-Command -Name 'ssms.exe' -ErrorAction SilentlyContinue",
    require   => Exec['Download SQL Management Studio'],
  }

  # Ensure the MSSQL service is running and set to automatic startup
  service { 'MSSQLSERVER':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Exec['Install SQL Server'],
  }
}
