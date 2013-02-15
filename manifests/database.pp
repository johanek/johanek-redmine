class redmine::database {

  if $redmine::database_server == 'localhost' { 

    Database {
      require => Class['mysql::server']
    }

    database { [$redmine::production_database,$redmine::development_database]:
      ensure  => present,
      charset => 'utf8'
    }

    database_user { "${redmine::database_user}@${redmine::database_server}":
      password_hash => mysql_password("${redmine::database_password}")
    }

    database_grant { "${redmine::database_user}@${redmine::database_server}/${redmine::production_database}":
      privileges => ['all']
    }

    database_grant { "${redmine::database_user}@${redmine::database_server}/${redmine::development_database}":
      privileges => ['all']
    }
    
  }

}