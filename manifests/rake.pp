#Class redmine::rake - DB migrate/prep tasks
class redmine::rake {

  Exec {
    path        => ['/bin','/usr/bin', '/usr/local/bin'],
    environment => ['HOME=/root','RAILS_ENV=production','REDMINE_LANG=en'],
    provider    => 'shell',
    cwd         => $redmine::webroot,
  }

  # Create session store
  exec { 'session_store':
    command => 'rake generate_session_store && touch .session_store',
    creates => "${redmine::webroot}/.session_store",
  }

  # Perform rails migrations
  exec { 'rails_migrations':
    command     => 'rake db:migrate',
    notify      => Class['apache::service'],
    refreshonly => true,
  }

  # Seed DB data
  exec { 'seed_db':
    command => 'rake redmine:load_default_data && touch .seed',
    creates => "${redmine::webroot}/.seed",
    notify  => Class['apache::service'],
    require => Exec['rails_migrations'],
  }

}
