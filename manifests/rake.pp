#Class redmine::rake - DB migrate/prep tasks
class redmine::rake {

  Exec {
    path        => ['/bin','/usr/bin', '/usr/local/bin'],
    environment => ['HOME=/root','RAILS_ENV=production','REDMINE_LANG=en'],
    provider    => 'shell',
    cwd         => $redmine::webroot,
  }

  if $redmine::bundle_exec {
    $bundle_exec = "bundle exec "
  }

  # Create secret_token
  exec { 'secret_token':
    command => "${bundle_exec}rake generate_secret_token && touch .secret_token",
    creates => "${redmine::webroot}/.secret_token"
  }

  # Perform rails migrations
  exec { 'rails_migrations':
    command => "${bundle_exec}rake db:migrate && touch .migrate",
    creates => "${redmine::webroot}/.migrate",
    notify  => $redmine::notify
  }

  # Seed DB data
  exec { 'seed_db':
    command => "${bundle_exec}rake redmine:load_default_data && touch .seed",
    creates => "${redmine::webroot}/.seed",
    notify  => $redmine::notify,
    require => Exec['rails_migrations']
  }


}
