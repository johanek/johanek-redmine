# Class redmine::install
class redmine::install {

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ]
  }

  package { 'bundler':
    ensure   => present,
    provider => gem
  } ->

  exec { 'bundle_redmine':
    command => "bundle install --gemfile ${redmine::install_dir}/Gemfile --without development test postgresql sqlite && touch .bundle_done",
    creates => "${redmine::install_dir}/.bundle_done",
    require => [ Package['bundler'], Package['make'], Package['gcc'] ],
  }
}
