# Runs a PVS fleet scan each time the PVS host boots. PVS keeps its scan list
# in memory, so without this its UI shows "No scans yet." after a restart.
class profile::pvs_rescan_on_boot {
  file { '/usr/local/sbin/pvs-rescan-on-boot':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/profile/pvs/pvs-rescan-on-boot',
  }

  file { '/etc/systemd/system/pvs-rescan-on-boot.service':
    ensure => file,
    mode   => '0644',
    source => 'puppet:///modules/profile/pvs/pvs-rescan-on-boot.service',
  }

  # Enable only. Setting ensure => running would start a new scan on every
  # Puppet run instead of once per boot.
  service { 'pvs-rescan-on-boot':
    enable  => true,
    require => File['/usr/local/sbin/pvs-rescan-on-boot', '/etc/systemd/system/pvs-rescan-on-boot.service'],
  }
}
