# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include k8s::shared::services
class k8s::shared::services {

  service { 'kubelet':
    ensure => running,
    enable => true,
  }
}
