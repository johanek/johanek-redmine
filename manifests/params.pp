# Class redmine::params
class redmine::params {

  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          if is_integer($::operatingsystemrelease) and $::operatingsystemrelease >= 19 or $::operatingsystemrelease == 'Rawhide' {
            $mysql_devel = 'mariadb-devel'
          } else {
            $mysql_devel = 'mysql-devel'
          }
        }
        /^(RedHat|CentOS|Scientific)$/: {
          if $::operatingsystemmajrelease >= 7 {
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

}
