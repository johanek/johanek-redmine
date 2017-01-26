# = Class: redmine
#
# This module installs redmine, running behind apache and passenger,
# and backed by eiter mysql or maria-db
#
# Tested on CentOS 6.5 and debian wheezy
#
#== Requirements
# Packages installed during process:
# All OS: make, gcc, tar and wget or your chosen vcs
# CentOS: mysql-devel or mariadb-devel, postgresql-devel, sqlite-devel, ImageMagick-devel, ruby-devel
# Debian: libmysql++-dev, libmysqlclient-dev, libmagickcore-dev, libmagickwand-dev, ruby-dev, imagemagick
#
# Gems installed during process: bundler
#
# Modules required: puppetlabs-mysql 2.0 or later, puppetlabs-stdlib, puppetlabs-apache, puppetlabs-concat
# Optional modules: puppetlabs-vcsrepo if you want to download redmine from a repository(the default)
#
#
#== Example
# class { 'apache': }
# class { 'apache::mod::passenger': }
# class { '::mysql::server': }
# class { 'redmine': }
#
# == Parameters
#
# [*version*]
#   Set to desired version.
#   Default: 2.2.3
#
# [*download_url*]
#   Download URL for redmine tar.gz when using wget as the provider.
#   The repository url otherwise.
#   When using wget, be sure to provide the full url.
#   Default: https://github.com/redmine/redmine
#
# [*provider*]
#   The VCS provider or wget.
#   When setting the provider to wget, be sure to set download_url
#   to a valid tar.gz archive.
#   To use the svn provider you have to provide the full url to the
#   tag or branch you want to download and unset the version.
#   Default: git
#
# [*database_server*]
#   Database server to use.
#   Default: 'localhost'
#   If server is not on localhost, the database and user must
#   be setup in advance.
#
# [*database_user*]
#   Database user.
#   Default: 'redmine'
#
# [*database_password*]
#   Database user password.
#   Default: 'redmine'
#
# [*production_database*]
#   Name of database to use for production environment.
#   Default: 'redmine'
#
# [*development_database*]
#   Name of database to use for development environment.
#   Default: 'redmine_development'
#
# [*database_adapter*]
#   Database adapter to use for database configuration.
#   Can be either 'mysql' for ruby 1.8, 'mysql2' for ruby 1.9 or 'postgresql'.
#   Default: undef (autodetects the correct mysql adapter)
#
# [*smtp_server*]
#   SMTP server to use.
#   Default: 'localhost'
#
# [*smtp_domain*]
#   Domain to send emails from.
#   Default: $::domain
#
# [*smtp_port*]
#   SMTP port to use.
#   Default: 25
#
# [*smtp_authentication*]
#   SMTP authentication mode: could be ':plain' or ':login' or ':cram_md5'. Set
#   to false to disable smtp_authentication.
#   Default: false
#
# [*smtp_ssl*]
#   Set to true to force connection to SMTP server to use SSL/TLS.
#   Default: false
#
# [*smtp_openssl_verify_mode*]
#   Set to 'none' to disable OpenSSL peer certificate verification. Other
#   possible values are: 'client_once' and 'fail_if_no_peer_cert'.
#   Default: 'peer'
#
# [*smtp_enable_starttls_auto*]
#   Set to true to enable SMTP/TLS (STARTTLS) when connecting to remote SMTP
#   server.
#   Default: true
#
# [*smtp_username*]
#   SMTP user name for authentication.
#   Default: none
#
# [*smtp_password*]
#   SMTP password for authentication.
#   Default: none
#
# [*webroot*]
#   Directory in which redmine web files will be installed.
#   Default: 'DOCROOT/redmine'
#   where DOCROOT is the document root of your apache server,
#   usually /var/www or /var/www/html
#
# [*install_dir*]
#   Path where redmine will be installed
#   Default: '/usr/src/redmine'
#
# [*vhost_aliases*]
#   Server aliases to use in the vhost config. Default 'redmine'. Expects a string.
#
# [*vhost_servername*]
#   Server name to use in the vhost config. Default 'redmine'. Expects a string.
#
# [*override_options*]
#   Extra options to add to configuration.yml. Empty by default. Expects a hash.
#
# [*plugins*]
#   Optional hash of plugins, which are passed to redmine::plugin
#
# [*www_subdir*]
#   Optional directory relative to the site webroot to install redmine in.
#   Undef by default. Expects a path string without leading slash.
#   When using this option the vhost config is your responsibility.
#
# [*create_vhost*]
#   Enable or disable vhost creation.
#   True by default.
#   When disabling this option the vhost config is your responsibility.
#
class redmine (
  $version                  = undef,
  $download_url             = 'https://github.com/redmine/redmine',
  $database_server          = 'localhost',
  $database_user            = 'redmine',
  $database_password        = 'redmine',
  $production_database      = 'redmine',
  $development_database     = 'redmine_development',
  $database_adapter         = undef,
  $smtp_server              = 'localhost',
  $smtp_domain              = $::domain,
  $smtp_port                = 25,
  $smtp_authentication      = false,
  $smtp_openssl_verify_mode = 'peer',
  $smtp_enable_starttls_auto= true,
  $smtp_ssl                 = false,
  $smtp_username            = '',
  $smtp_password            = '',
  $vhost_aliases            = 'redmine',
  $vhost_servername         = 'redmine',
  $webroot                  = "${apache::docroot}/redmine",
  $install_dir              = '/usr/src/redmine',
  $provider                 = 'git',
  $override_options         = {},
  $plugins                  = {},
  $www_subdir               = undef,
  $create_vhost             = true,
) {

  validate_bool($smtp_ssl, $smtp_enable_starttls_auto)
  validate_string($smtp_openssl_verify_mode)
  unless $smtp_openssl_verify_mode in ['none', 'peer', 'client_once', 'fail_if_no_peer_cert'] {
    fail("\$smtp_openssl_verify_mode MUST be one of 'none', 'peer', 'client_once' or 'fail_if_no_peer_cert'. Got '$smtp_openssl_verify_mode'")
  }
  unless $smtp_authentication == false or $smtp_authentication in [':plain', ':login', ':cram_md5'] {
    fail("\$smtp_authentication MUST be one of false, ':login', ':plain' or ':cram_md5'. Got '$smtp_authentication'")
  }

  class { 'redmine::params': } ->
  class { 'redmine::download': } ->
  class { 'redmine::config': } ->
  class { 'redmine::install': } ->
  class { 'redmine::database': } ->
  class { 'redmine::rake': }
}
