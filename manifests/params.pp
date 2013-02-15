# Class redmine::params
class redmine::params  {

  $download_url = $redmine::version ? {
    '2.2.3' => 'http://rubyforge.org/frs/download.php/76771/redmine-2.2.3.tar.gz',
    '2.2.2' => 'http://rubyforge.org/frs/download.php/76722/redmine-2.2.2.tar.gz',
    '2.2.1' => 'http://rubyforge.org/frs/download.php/76677/redmine-2.2.1.tar.gz',
    default => $redmine::download_url
  }
  
  # Locally scope variables from other classes
  $apache_user = $apache::params::user
  $apache_group = $apache::params::group
  
}
