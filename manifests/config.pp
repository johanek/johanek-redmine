# Class redmine::config
class redmine::config {

  require 'apache'

  file { '/etc/apache2/sites-enabled/000-default':
    ensure => absent
  }

  File {
    owner => $apache::params::apache_user,
    group => $apache::params::apache_group,
    mode  => '0644'
  }

  file { $redmine::webroot:
    ensure => link,
    target => "/usr/src/redmine-${redmine::version}"
  }

  Exec {
    cmd => "/bin/chown -R ${redmine::params::apache_user}.${redmine::params::apache_group} /usr/src/redmine-${redmine::version}"
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
    servername    => '*',
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
