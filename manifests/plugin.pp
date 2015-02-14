define redmine::plugin (
  $source   = undef,
  $version  = undef,
  $provider = 'git',
  $ensure   = present,
  $migrate  = false,
  $bundle   = false,
) {

  $install_dir = "${redmine::install_dir}/plugins/${name}"
  if $ensure == purged or $ensure == absent {

    if $migrate {
      exec { "rake redmine:plugins:migrate NAME=${name} VERSION=0":
        notify      => Class['apache::service'],
        path        => ['/bin','/usr/bin', '/usr/local/bin'],
        environment => ['HOME=/root','RAILS_ENV=production','REDMINE_LANG=en'],
        provider    => 'shell',
        cwd         => $redmine::webroot,
        before      => File[$install_dir],
        onlyif      => "test -d ${install_dir}",
      }
    }
    file { $install_dir:
      ensure  => $ensure,
      force   => true,
      require => Class['redmine'],
    }

  } else {

    if $source == undef {
      fail("no source specified for redmine plugin '${name}'")
    }
    validate_string($source)

    case $provider {
      'svn' : {
        $provider_package = 'subversion'
      }
      'hg': {
        $provider_package = 'mercurial'
      }
      default: {
        $provider_package = $provider
      }
    }
    ensure_packages($provider_package)

    if $migrate and $bundle {
      $notify = [Exec['bundle_update'], Exec['plugin_migrations']]
    } elsif $migrate {
      $notify = Exec['plugin_migrations']
    } elsif $bundle {
      $notify = Exec['bundle_update']
    } else {
      $notify = undef
    }

    vcsrepo { $install_dir:
      ensure   => $ensure,
      revision => $version,
      source   => $source,
      provider => $provider,
      notify   => $notify,
      require  => [ Package[$provider_package]
                  , Class['redmine'] ]
    }
  }
}
