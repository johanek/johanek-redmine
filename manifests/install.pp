# Class redmine::install
class redmine::install {

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ]
  }

  package { 'bundler':
    ensure    => present,
    provider  => gem
  } ->

  exec { 'bundle_redmine':
    command => "bundle install --gemfile /usr/src/redmine-${redmine::version}/Gemfile --without development test postgresql sqlite && touch .bundle_done",
    creates => "/usr/src/redmine-${redmine::version}/.bundle_done",
    require => [ Package['bundler'], Package['make'], Package['gcc'] ],
  }
}
