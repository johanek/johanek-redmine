# Class redmine::params
class redmine::params {

  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          if versioncmp($::operatingsystemrelease, '19') >= 0 or $::operatingsystemrelease == 'Rawhide' {
            $mysql_devel = 'mariadb-devel'
          } else {
            $mysql_devel = 'mysql-devel'
          }
        }
        /^(RedHat|CentOS|Scientific)$/: {
          if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
            $mysql_devel = 'mariadb-devel'
          } else {
            $mysql_devel = 'mysql-devel'
          }
        }
        default: {
          $mysql_devel = 'mysql-devel'
        }
      }
    }
  }
  if $redmine::database_adapter {
    $real_adapter = $redmine::database_adapter
  } elsif versioncmp($::rubyversion, '1.9') >= 0 {
    $real_adapter = 'mysql2'
  } else {
    $real_adapter = 'mysql'
  }

  case $redmine::provider {
    'svn' : {
      $provider_package = 'subversion'
    }
    'hg': {
      $provider_package = 'mercurial'
    }
    default: {
      $provider_package = $redmine::provider
    }
  }
}
