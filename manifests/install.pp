# Class redmine::install
class redmine::install {


  # Install dependencies

  $generic_packages = [ 'make', 'gcc' ]
  $debian_packages  = [ 'libmysql++-dev', 'libmysqlclient-dev', 'libmagickcore-dev', 'libmagickwand-dev', 'ruby-dev' ]
  $default_packages = ['postgresql-devel', 'sqlite-devel', 'ImageMagick-devel', 'ruby-devel', 'mysql-devel' ]

  case $::osfamily {
    'Debian':   { $packages = concat($generic_packages, $debian_packages) }
    'RedHat':   {
      case $::operatingsystem {
        'Fedora': {
          if is_integer($::operatingsystemrelease) and $::operatingsystemrelease >= 19 or $::operatingsystemrelease == 'Rawhide' {
              $provider = 'mariadb-devel'
            } else {
              $provider = 'mysql-devel'
            }
        }
        /^(RedHat|CentOS|Scientific)$/: {
          if $::operatingsystemmajrelease >= 7 {
              $provider = 'mariadb-devel'
            } else {
              $provider = 'mysql-devel'
            }
        }
        default: {
          $provider = 'mysql-devel'
        }
      }
      $redhat_packages = ['postgresql-devel', 'sqlite-devel', 'ImageMagick-devel', 'ruby-devel', $provider ]
      $packages = concat($generic_packages, $redhat_packages)
    }
    default:    { $packages = concat($generic_packages, $default_packages) }
  }

  ensure_packages($packages)

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
