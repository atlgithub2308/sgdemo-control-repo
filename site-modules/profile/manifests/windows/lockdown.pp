# Password and lockout policy for the demo Windows servers, which face RDP
# brute-force attempts from the internet (see the 2026-10-18 win3 incident).
# The CIS controls applied come from each node's sce_windows::config in Hiera.
class profile::windows::lockdown {
  include sce_windows

  # Disable the built-in Administrator, the most-guessed account name, which
  # can be exempt from account lockout. security_option compares the current
  # value first, so it only reports a change when it really makes one (the
  # dsc_securityoption it replaces reported a corrective change on every run).
  security_option { 'EnableAdminAccount':
    ensure => present,
    value  => '0',
  }
}
