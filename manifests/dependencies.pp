# Class redmine::dependencies
class redmine::dependencies  {

  exec { 'gem-bundler':
    command => 'gem install bundler',
    creates => '/usr/bin/bundle',
  }

  if !defined(Package["wget"]) {
    package { 'wget':
      ensure  => present,
    }
  }

  if !defined(Package["tar"]) {
    package { 'tar':
      ensure  => present,
    }
  }

  if !defined(Package["make"]) {
    package { 'make':
      ensure  => present,
    }
  }

  if !defined(Package["gcc"]) {
    package { 'gcc':
      ensure  => present,
    }
  }

  if $::osfamily == 'Debian' {
    if !defined(Package["libmysql++-dev"]) {
      package { 'libmysql++-dev':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
    if !defined(Package["libmysqlclient-dev"]) {
      package { 'libmysqlclient-dev':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
    if !defined(Package["libmagickcore-dev"]) {
      package { 'libmagickcore-dev':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
    if !defined(Package["libmagickwand-dev"]) {
      package { 'libmagickwand-dev':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
  } elsif $::osfamily == 'Redhat' {
    if !defined(Package["mysql-devel"]) {
      package { 'mysql-devel':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
    if !defined(Package["postgresql-devel"]) {
      package { 'postgresql-devel':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
    if !defined(Package["sqlite-devel"]) {
      package { 'sqlite-devel':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
    if !defined(Package["ImageMagick-devel"]) {
      package { 'ImageMagick-devel':
        ensure => present,
        before => Exec['bundle_redmine'],
      }
    }
  }
}
