# Class redmine::install
class redmine::install {

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ]
  }

  # Install dependencies

  $generic_packages = [ 'wget', 'tar', 'make', 'gcc' ]
  $debian_packages = [ 'libmysql++-dev', 'libmysqlclient-dev', 'libmagickcore-dev', 'libmagickwand-dev', 'ruby-dev', 'libapache2-mod-passenger']
  $redhat_packages = [ 'mysql-devel', 'postgresql-devel', 'sqlite-devel', 'ImageMagick-devel' ]

  case $::osfamily {
    'Debian':   { $packages = concat($generic_packages, $debian_packages) }
    default:    { $packages = concat($generic_packages, $redhat_packages) }
  }

  ensure_packages($packages)

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
