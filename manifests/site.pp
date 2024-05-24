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
  include declared_classes
  user { 'pacificuser1':
    ensure => 'absent',
  }

  file { '/myfolder/myfile.txt':
    ensure  => 'file',
    content => "my file new content.\n",
  }

}

node 'pacificwin0.se.automationdemos.com' {
  include declared_classes
  include profile::platform::baseline

}



# Uncomment the line below to enable ServiceNow Node Classification
# include servicenow_cmdb_integration::classification
