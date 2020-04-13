# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include k8s::shared::packages
class k8s::shared::packages (
  Array  $additional_packages,
  String $version,
  ) {

  $_version = regsubst($version, 'v', '')

  package { 'kubectl':
    ensure => "${_version}-0",
  }

  package { 'kubelet':
    ensure  => "${_version}-0",
    require => Package['kubectl'],
  }

  package { 'kubeadm':
    ensure  => "${_version}-0",
    require => Package['kubelet'],
  }

  package { $additional_packages:
    ensure  => present,
    require => Package['kubeadm'],
  }
}
