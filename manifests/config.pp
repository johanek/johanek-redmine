# Class redmine::config
class redmine::config {

  if $redmine::configure_apache {

    require 'apache'

    File {
      owner => $apache::params::user,
      group => $apache::params::group,
      mode  => '0644'
    }

    file { $redmine::webroot:
      ensure => link,
      target => $redmine::install_dir
    }

  } else {

    File {
      owner => $redmine::user,
      group => $redmine::group,
      mode  => '0644'
    }

    file { $redmine::webroot:
      ensure => directory,
    }

  }

  # user switching makes passenger run redmine as the owner of the startup file
  # which is config.ru or config/environment.rb depending on the Rails version
  file { [
      "${redmine::install_dir}/config.ru",
      "${redmine::install_dir}/config/environment.rb"]:
    ensure => 'present',
  }

  file { [
      "${redmine::install_dir}/files",
      "${redmine::install_dir}/tmp",
      "${redmine::install_dir}/tmp/sockets",
      "${redmine::install_dir}/tmp/thumbnails",
      "${redmine::install_dir}/tmp/cache",
      "${redmine::install_dir}/tmp/test",
      "${redmine::install_dir}/tmp/pdf",
      "${redmine::install_dir}/tmp/sessions",
      "${redmine::install_dir}/public/plugin_assets",
      "${redmine::install_dir}/log"]:
    ensure  => 'directory',
  }

  file { "${redmine::webroot}/config/database.yml":
    ensure  => present,
    content => template('redmine/database.yml.erb'),
    require => File[$redmine::webroot]
  }

  file { "${redmine::webroot}/config/configuration.yml":
    ensure  => present,
    content => template('redmine/configuration.yml.erb'),
    require => File[$redmine::webroot]
  }

  if $redmine::configure_apache {

    apache::vhost { 'redmine':
      port            => '80',
      docroot         => "${redmine::webroot}/public",
      servername      => $redmine::vhost_servername,
      serveraliases   => $redmine::vhost_aliases,
      options         => 'Indexes FollowSymlinks ExecCGI',
      custom_fragment => 'RailsBaseURI /',
    }

  }

  # Log rotation
  file { '/etc/logrotate.d/redmine':
    ensure  => present,
    content => template('redmine/redmine-logrotate.erb'),
    owner   => 'root',
    group   => 'root'
  }

}
