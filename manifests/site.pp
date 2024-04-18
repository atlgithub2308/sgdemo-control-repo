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

node 'puppet.se.automationdemos.com' {
  
  include device_manager

  user { 'pacificuser1':
    ensure => 'absent',
  }

  file { '/myfolder/myfile.txt':
    ensure  => 'file',
    content => "my file new content.\n",
  }

  device_manager { 'cisco.example.com':
    type        => 'cisco_ios',
    credentials => {
      address         => 'devnetsandboxiosxe.cisco.com',
      port            => 22,
      username        => 'admin',
      password        => 'C1sco12345',
      enable_password => 'C1sco12345',
    },
  }

}

#node /^agent[\w._%+-]+/ {
#  user { ['perodua_user1', 'perodua_user2']:
#    ensure  => 'absent',
#  }

# Uncomment the line below to enable ServiceNow Node Classification
# include servicenow_cmdb_integration::classification
