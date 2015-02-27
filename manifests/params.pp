# Class redmine::params
class redmine::params {

  case $::osfamily {
    'RedHat': {
      $www_user  = 'apache'
      $www_group = 'apache'
      case $::operatingsystem {
        'Fedora': {
          if versioncmp($::operatingsystemrelease, '19') >= 0 or $::operatingsystemrelease == 'Rawhide' {
            $mysql_devel_package = 'mariadb-devel'
          } else {
            $mysql_devel_package = 'mysql-devel'
          }
        }
        /^(RedHat|CentOS|Scientific)$/: {
          if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
            $mysql_devel_package = 'mariadb-devel'
          } else {
            $mysql_devel_package = 'mysql-devel'
          }
        }
        default: {
          $mysql_devel_package = 'mysql-devel'
        }
      }
    }
  }

  if versioncmp($::rubyversion, '1.9') >= 0 {
    $database_real_adapter = 'mysql2'
  } else {
    $database_real_adapter = 'mysql'
  }
}
