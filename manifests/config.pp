# Class redmine::config
class redmine::config {

  require 'apache'

  file { '/etc/apache2/sites-enabled/000-default':
    ensure => absent
  }

  File {
    owner => $apache::params::user,
    group => $apache::params::group,
    mode  => '0644'
  }

  file { $redmine::webroot:
    ensure => link,
    target => "/usr/src/redmine-${redmine::version}"
  }

  # user switching makes passenger run redmine as the owner of the startup file
  # which is config.ru or config/environment.rb depending on the Rails version
  file { [
      "/usr/src/redmine-${redmine::version}/config.ru",
      "/usr/src/redmine-${redmine::version}/config/environment.rb"]:
    ensure => 'present',
  }

  file { [
      "/usr/src/redmine-${redmine::version}/files",
      "/usr/src/redmine-${redmine::version}/tmp",
      "/usr/src/redmine-${redmine::version}/tmp/pdf",
      "/usr/src/redmine-${redmine::version}/public/plugin_assets",
      "/usr/src/redmine-${redmine::version}/log"]:
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

  apache::vhost { 'redmine':
    port          => '80',
    docroot       => "${redmine::webroot}/public",
    servername    => $redmine::vhost_servername,
    serveraliases => $redmine::vhost_aliases,
    options       => 'Indexes FollowSymlinks ExecCGI',
    custom_fragment => 'RailsBaseURI /',
  }

  # Log rotation
  file { '/etc/logrotate.d/redmine':
    ensure => present,
    content => template('redmine/redmine-logrotate.erb'),
    owner  => 'root',
    group  => 'root'
  }

}
