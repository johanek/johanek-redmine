# Class redmine::download
class redmine::download {

    # Install dependencies

    $generic_packages = [ 'wget', 'tar', 'make', 'gcc' ]
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
