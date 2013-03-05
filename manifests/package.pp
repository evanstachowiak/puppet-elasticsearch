# == Class: elasticsearch::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'elasticsearch::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class elasticsearch::package {

  #### Package management

  # set params: in operation
  if $elasticsearch::ensure == 'present' {

    $package_ensure = $elasticsearch::autoupgrade ? {
      true  => 'latest',
      false => 'present',
    }

  # set params: removal
  } else {
    $package_ensure = 'purged'
  }

  if $elasticsearch::provider == 'dpkg' {
    Exec['download-elasticsearch-deb'] -> Exec['install_elasticsearch_deb']
    exec { 'download-elasticsearch-deb':
      command => "/usr/bin/wget -O /tmp/elasticsearch-${elasticsearch::version}.deb ${elasticsearch::dl_base_url}${elasticsearch::version}.deb",
      unless  => '/usr/bin/dpkg -s elasticsearch',
    }
    exec { 'install_elasticsearch_deb':
      command => "/usr/bin/dpkg -i /tmp/elasticsearch-${elasticsearch::version}.deb;/usr/bin/apt-get -fy install",
      unless  => '/usr/bin/dpkg -s elasticsearch',
    }
  }
  else {
    # action
    package { $elasticsearch::params::package:
      ensure   => $package_ensure,
    }
  }

}
