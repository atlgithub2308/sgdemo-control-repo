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

  user { 'pacificuser1':
    ensure => 'absent',
  }

  file { '/myfolder/myfile.txt':
    ensure  => 'file',
    content => "my file new content.\n",
  }

}

#node /^agent[\w._%+-]+/ {
#  user { ['perodua_user1', 'perodua_user2']:
#    ensure  => 'absent',
#  }

# Uncomment the line below to enable ServiceNow Node Classification
# include servicenow_cmdb_integration::classification
