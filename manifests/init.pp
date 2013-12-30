# = Class: redmine
#
# This module installs redmine, running behind apache and passenger, and backed by mysql
#
# Only tested on CentOS 6.3
#
#== Requirements
# Packages: wget, tar, make, gcc, mysql-devel, postgresql-devel, sqlite-devel, ImageMagick-devel
# Gems: bundler
# Modules: johanek-apache, johanek-passenger, puppetlabs-mysql (mysql::server)
#
#== Example
# class { 'apache': }
# class { 'passenger': }
# class { 'mysql': }
# class { 'mysql::server': }
# class { 'redmine': }
#
# == Parameters
#
# [*version*]
#   Set to desired version. Default: 2.2.3
#
# [*download_url*]
#   Download URL for redmine tar.gz. If you want to install an unsupported version, this is required.
#   Versions Supported: 2.2.1, 2.2.2, 2.2.3
#
# [*database_server*]
#   Database server to use. Default: 'localhost'
#   If server is not on localhost, the database and user must be setup in advance.
#
# [*database_user*]
#   Database user. Default: 'redmine'
#
# [*database_password*]
#   Database user password. Default: 'redmine'
#
# [*production_database*]
#   Name of database to use for production environment. Default: 'redmine'
#
# [*development_database*]
#   Name of database to use for development environment. Default: 'redmind_development'
#
# [*database_adapter*]
#   Database adapter to use for database configuration. 'mysql' for ruby 1.8, 'mysql2' for ruby 1.9. Default: 'mysql'
#
# [*smtp_server*]
#   SMTP server to use. Default: 'localhost'
#
# [*smtp_domain*]
#   Domain to send emails from. Default: $::domain
#
# [*smtp_port*]
#   SMTP port to use. Default: 25
#
# [*smtp_authentication*]
#   SMTP authentication mode. Default: ':login'
#
# [*smtp_username*]
#   SMTP user name for authentication. Default: none
#
# [*smtp_password*]
#   SMTP password for authentication. Default: none
#
# [*webroot*]
#   Directory in which redmine web files will be installed. Default: '/var/www/html/redmine'
#
class redmine (
  $version              = '2.2.3',
  $download_url         = '',
  $database_server      = 'localhost',
  $database_user        = 'redmine',
  $database_password    = 'redmine',
  $production_database  = 'redmine',
  $development_database = 'redmine_development',
  $database_adapter     = 'mysql',
  $smtp_server          = 'localhost',
  $smtp_domain          = $::domain,
  $smtp_port            = 25,
  $smtp_authentication  = false,
  $smtp_username        = '',
  $smtp_password        = '',
  $vhost_aliases        = 'redmine',
  $webroot              = '/var/www/html/redmine',
) {

  class { 'redmine::dependencies': } ->
  class { 'redmine::params': } ->
  class { 'redmine::install': } ->
  class { 'redmine::config': } ->
  class { 'redmine::database': } ->
  class { 'redmine::rake': }

}