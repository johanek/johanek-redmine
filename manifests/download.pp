# Class redmine::download
class redmine::download {

  # Install redmine from source

  Exec {
    cwd  => '/usr/src',
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ]
  }

  if $redmine::provider != 'wget' {
    vcsrepo { 'redmine_source':
      revision => $redmine::version,
      source   => $redmine::download_url,
      provider => $redmine::provider,
      path     => $redmine::install_dir
    }
  }
  else {
    ensure_packages([ 'tar', 'wget' ])
    exec { 'redmine_source':
      command => "wget -O redmine.tar.gz ${redmine::download_url}",
      creates => '/usr/src/redmine.tar.gz',
      require => Package['wget'],
    } ->
    exec { 'extract_redmine':
      command => "mkdir -p ${redmine::install_dir} && tar xvzf redmine.tar.gz --strip-components=1 -C ${redmine::install_dir}",
      creates => $redmine::install_dir,
      require => Package['tar'],
    }
  }
}
