require 'spec_helper'

describe 'redmine', :type => :class do

  let :facts do
    {
      :osfamily                   => 'Redhat',
      :operatingsystemrelease     => '6',
      :operatingsystemmajrrelease => '6',
      :domain                     => 'test.com',
      :concat_basedir             => '/dne'
    }
  end

  context 'no parameters' do
    it { should create_class('redmine::config')}
    it { should create_class('redmine::download')}
    it { should create_class('redmine::install')}
    it { should create_class('redmine::database')}
    it { should create_class('redmine::rake')}

    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/adapter: mysql/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/database: redmine/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/database: redmine_development/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/host: localhost/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/username: redmine/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/password: redmine/)}

    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/address: localhost/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/domain: test.com/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/port: 25/)}

    it { should contain_package('make')}
    it { should contain_package('gcc')}

    ['redmine', 'redmine_development'].each do |db|
      it { should contain_mysql_database(db).with(
        'ensure'  => 'present',
        'charset' => 'utf8'
      )}

      it { should contain_mysql_grant("redmine@localhost/#{db}.*").with(
        'privileges' => ['all']
      )}
    end

    it { should contain_mysql_user('redmine@localhost') }

  end

  context 'set version 2.2.2' do
    let :params do
      {:version => '2.2.2'}
    end

    it { should contain_vcsrepo('redmine_source').with(
      'revision' => '2.2.2',
      'provider' => 'git',
      'source'   => 'https://github.com/redmine/redmine',
      'path'     => '/usr/src/redmine'
    )}

    it { should contain_file('/var/www/html/redmine').with(
      'ensure' => 'link',
      'target' => '/usr/src/redmine'
    )}
  end

  context 'wget download' do
    let :params do
      {
        :provider     => 'wget',
        :download_url => 'example.com/redmine.tar.gz'
      }
    end

    it { should contain_package('wget')}
    it { should contain_package('tar')}

    it { should contain_exec('redmine_source').with(
      'cwd'     => '/usr/src',
      'path'    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ],
      'command' => 'wget -O redmine.tar.gz example.com/redmine.tar.gz',
      'creates' => '/usr/src/redmine.tar.gz'
    )}

    it { should contain_exec('extract_redmine').with(
      'cwd'     => '/usr/src',
      'path'    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ],
      'command' => 'mkdir -p /usr/src/redmine && tar xvzf redmine.tar.gz --strip-components=1 -C /usr/src/redmine',
      'creates' => '/usr/src/redmine'
    )}

  end

  context 'set remote db params' do
    let :params do
      {
        :database_adapter     => 'mysql2',
        :database_server      => 'db1',
        :database_user        => 'dbuser',
        :database_password    => 'password',
        :production_database  => 'redproddb',
        :development_database => 'reddevdb'
      }
    end

    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/adapter: mysql2/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/database: redproddb/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/database: reddevdb/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/host: db1/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/username: dbuser/)}
    it { should contain_file('/var/www/html/redmine/config/database.yml').with_content(/password: password/)}

    it { should_not contain_mysql_database }
    it { should_not contain_mysql_user }
    it { should_not contain_mysql_grant }

  end

  context 'set override_options' do
    let :params do
      {
        :override_options => { 'foo' => 'bar', 'additional' => 'options' }
      }
    end

    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/foo: bar/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/additional: options/)}

  end

  context 'set local db params' do
    let :params do
      {
        :database_server      => 'localhost',
        :database_user        => 'dbuser',
        :database_password    => 'password',
        :production_database  => 'redproddb',
        :development_database => 'reddevdb'
      }
    end

    ['redproddb', 'reddevdb'].each do |db|
      it { should contain_mysql_database(db).with(
        'ensure'  => 'present',
        'charset' => 'utf8'
      )}

      it { should contain_mysql_grant("dbuser@localhost/#{db}.*").with(
        'privileges' => ['all']
      )}
    end

    it { should contain_mysql_user('dbuser@localhost') }


  end

  context 'set mail params' do
    let :params do
      {
        :smtp_server         => 'smtp',
        :smtp_domain         => 'google.com',
        :smtp_port           => 1234,
        :smtp_authentication => true,
        :smtp_username       => 'user',
        :smtp_password       => 'password'
      }
    end

    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/address: smtp/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/domain: google.com/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/port: 1234/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/authentication: :login/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/user_name: user/)}
    it { should contain_file('/var/www/html/redmine/config/configuration.yml').with_content(/password: password/)}
  end

  context 'set webroot' do
    let :params do
      {
        :webroot  => '/opt/redmine'
      }
    end

    it { should contain_file('/opt/redmine').with({'ensure' => 'link'})}
    it { should contain_file('/opt/redmine/config/configuration.yml')}
    it { should contain_file('/opt/redmine/config/configuration.yml')}
  end

  context 'debian' do
    let :facts do
      {
        :osfamily                   => 'Debian',
        :operatingsystemrelease     => '6',
        :operatingsystemmajrrelease => '6',
        :concat_basedir             => '/dne'
      }
    end

    it { should contain_package('libmysql++-dev')}
    it { should contain_package('libmysqlclient-dev')}
    it { should contain_package('libmagickcore-dev')}
    it { should contain_package('libmagickwand-dev')}

  end

  context 'redhat' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystemrelease => '6',
        :operatingsystemmajrrelease => '6',
        :concat_basedir => '/dne'
      }
    end

    it { should contain_package('mysql-devel')}
    it { should contain_package('postgresql-devel')}
    it { should contain_package('sqlite-devel')}
    it { should contain_package('ImageMagick-devel')}
  end

end
