# Class redmine::install
class redmine::install {

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ]
  }

  exec { 'redmine_source':
    command => "wget ${redmine::params::download_url}",
    creates => "/usr/src/redmine-${redmine::version}.tar.gz",
  } ->

  exec { 'extract_redmine':
    command => "/bin/tar xvzf redmine-${redmine::version}.tar.gz",
    creates => "/usr/src/redmine-${redmine::version}"
  } ->

  exec { 'bundle_redmine':
    command => "bundle install --gemfile /usr/src/redmine-${redmine::version}/Gemfile --without development test postgresql sqlite && touch .bundle",
    creates => "/usr/src/redmine-${redmine::version}/.bundle",
  }
}
