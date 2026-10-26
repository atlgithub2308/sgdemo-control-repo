# Disables the built-in Administrator on the demo Windows servers, which face
# RDP brute-force attempts from the internet (see the 2026-10-18 win3 incident).
# It is the most-guessed account name and can be exempt from account lockout.
#
# The CIS password and lockout controls come from sce_windows, configured per
# node in Hiera. sce_windows is declared in the PE console (node group wingrp)
# for win1 and win2, and in site.pp for win3, so it is not included here.
class profile::windows::lockdown {
  # security_option compares the current value first, so it only reports a
  # change when it really makes one (the dsc_securityoption it replaces
  # reported a corrective change on every run).
  security_option { 'EnableAdminAccount':
    ensure => present,
    value  => '0',
  }
}
