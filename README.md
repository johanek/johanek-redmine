**This module is no longer under active development**

I'm no longer using redmine, so this module isn't being kept up to date. If you're looking for an alternative,
this module looks to be actively developed:

https://forge.puppetlabs.com/velaluqa/redmine/readme

If you're interested in taking over this module, get in touch. Otherwise, I'll merge PRs that have passing tests
but I won't be able to work any issues sorry!

johanek-redmine
---------------

[![Build Status](https://travis-ci.org/johanek/johanek-redmine.png)](http://travis-ci.org/johanek/johanek-redmine)

This module installs redmine, running behind apache and passenger, and backed by mysql or mariadb

Tested on CentOS 6.5 and debian wheezy

Requirements
------------

Packages installed during process:
All OS: wget, tar, make, gcc
CentOS: mysql-devel or mariadb-devel, postgresql-devel, sqlite-devel, ImageMagick-devel, ruby-devel
Debian: libmysql++-dev, libmysqlclient-dev, libmagickcore-dev, libmagickwand-dev, ruby-dev

Gems installed during process: bundler

Modules required: puppetlabs-mysql 2.0 or later, puppetlabs-stdlib, puppetlabs-apache, puppetlabs-concat
Optional modules: puppetlabs-vcsrepo if you want to download redmine from a repository(the default)

Example Usage
-------------

To install the default version of redmine

    class { 'apache': }
    class { 'apache::mod::passenger': }
    class { '::mysql::server': }
    class { 'redmine': }

To install version 2.5.0 from the official svn repository

    class { 'apache': }
    class { 'apache::mod::passenger': }
    class { '::mysql::server': }
    class { 'redmine':
      download_url => 'svn.redmine.org/redmine/tags/2.5.0',
      provider     => 'svn',
      version      => 'HEAD',
    }




Parameters
----------

**version**

  Set to desired version. Default: 2.2.3

**download_url**

  Download URL for redmine tar.gz when using wget as the provider. The repository url otherwise.
  When using wget, be sure to provide the full url.
  Default: https://github.com/redmine/redmine

**provider**

  The VCS provider or wget.
  When setting the provider to wget, be sure to set download_url to a valid tar.gz archive.
  To use the svn provider you have to provide the full url to the tag or branch you want to download and unset the version.
  Default: git

**database_server**

  Database server to use. Default: 'localhost'
  If server is not on localhost, the database and user must be setup in advance.

**database_user**

  Database user. Default: 'redmine'

**database_password**

  Database user password. Default: 'redmine'

**production_database**

  Name of database to use for production environment. Default: 'redmine'

**development_database**

  Name of database to use for development environment. Default: 'redmind_development'

**database_adapter**

  Database adapter to use for database configuration. 'mysql' for ruby 1.8, 'mysql2' for ruby 1.9. Default: 'mysql'

**smtp_server**

  SMTP server to use. Default: 'localhost'

**smtp_domain**

  Domain to send emails from. Default: $::domain

**smtp_port**

  SMTP port to use. Default: 25

**smtp_authentication**

  Toggle SMTP authentication. Default: false

**smtp_username**

  SMTP user name for authentication. Default: none

**smtp_password**

  SMTP password for authentication. Default: none

**vhost_aliases**

  Server aliases to use in the vhost config. Default 'redmine'. Expects a string.

**vhost_servername**

  Server name to use in the vhost config. Default 'redmine'. Expects a string.

**webroot**

  Directory in which redmine web files will be installed. Default: '/var/www/html/redmine'

**install_dir**
  Path where redmine will be installed
  Default: '/usr/src/redmine'

