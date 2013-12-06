# Class redmine::dependencies
class redmine::dependencies  {

  exec { 'gem-rails':
    command => 'gem install rails':
    creates => '/usr/bin/rails',
  }

  exec { 'gem-bundler':
    command => 'gem install bundler':
    creates => '/usr/bin/bundle',
    require => Exec['gem-rails'],
  }

  if $::osfamily == 'Debian' {
    package {['libmysql++-dev','libmysqlclient-dev','libmagickcore-dev','libmagickwand-dev']:
      ensure => installed,
      before => Exec['bundle_redmine'],
    }
  }
}
