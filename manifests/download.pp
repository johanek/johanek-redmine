# Class redmine::download
class redmine::download {
    # Install redmine from source

    vcsrepo { 'redmine_source':
        revision => "${redmine::version}",
        source   => "${redmine::params::download_url}",
        provider => 'git',
        path     => "/usr/src/redmine-${redmine::version}"
    }
}
