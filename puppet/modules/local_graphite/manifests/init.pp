# Helper class for our CentOS Graphite install.
# Makes a few assumptions, not very modular.
# Note that we also modify some settings through hiera.
class local_graphite {
  include graphite

  Class['graphite'] ~> Service['httpd']

  file { '/usr/lib/python2.6/site-packages/graphite/initial_data.json':
    content => template("${module_name}/initial_data.json.erb"),
    owner   => 'apache',
    group   => 'apache',
    mode    => 0400,
    require => Package['graphite-web'],
  } ->

  exec { 'syncdb':
    cwd     => '/usr/lib/python2.6/site-packages/graphite',
    command => '/usr/bin/python manage.py syncdb --noinput',
    user    => 'apache',
    creates => '/var/lib/graphite-web/graphite.db',
    before  => Service['httpd'],
  }

  file { '/etc/httpd/conf.d/graphite-web.conf':
    source  => "puppet:///modules/${module_name}/graphite-web.conf",
    owner   => root,
    group   => root,
    mode    => 0444,
    notify  => Service['httpd'],
    require => Package['graphite-web'],
  }
}