# Class redmine::install
class redmine::install {

  # Install dependencies

  $generic_packages = [ 'make', 'gcc' ]
  $debian_packages  = [ 'libmysql++-dev', 'libmysqlclient-dev', 'libmagickcore-dev', 'libmagickwand-dev', 'ruby-dev', 'libpq-dev', 'imagemagick' ]
  $redhat_packages  = [ 'postgresql-devel', 'sqlite-devel', 'ImageMagick-devel', 'ruby-devel', $::redmine::mysql_devel_package ]

  case $::osfamily {
    'Debian':   { $packages = concat($generic_packages, $debian_packages) }
    'RedHat':   { $packages = concat($generic_packages, $redhat_packages) }
    default:    { $packages = concat($generic_packages, $redhat_packages) }
  }

  ensure_packages($packages)

  case $redmine::database_adapter {
    'postgresql' : {
      $without_gems = 'development test sqlite mysql'
    }
    default: {
      $without_gems = 'development test sqlite postgresql'
    }
  }

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ]
  }

  package { 'bundler':
    ensure   => present,
    provider => gem
  } ->

  exec { 'bundle_redmine':
    command => "bundle install --gemfile ${redmine::install_dir}/Gemfile --without ${without_gems}",
    creates => "${redmine::install_dir}/Gemfile.lock",
    require => [ Package['bundler'], Package['make'], Package['gcc'], Package[$packages] ],
    notify  => Exec['rails_migrations'],
  }

  if $redmine::provider != 'wget' {
    exec { 'bundle_update':
      cwd         => $redmine::install_dir,
      command     => 'bundle update',
      refreshonly => true,
      subscribe   => Vcsrepo['redmine_source'],
      notify      => Exec['rails_migrations'],
      require     => Exec['bundle_redmine'],
    }
  }
}
