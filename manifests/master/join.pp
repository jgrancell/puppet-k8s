# @summary Joins a Kubernetes control plane
#
# Joins a Kubernetes control plane
#
# @example
#   include k8s::master::join
class k8s::master::join (
  String $apiserver,
  ) {

  ## TODO: Add more unless checking here -- very fragile
  exec { 'kubeadm-join':
    command   => "kubeadm join --config /etc/kubernetes/kubeadm/master.yaml ${apiserver}",
    logoutput => true,
    path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    unless    => 'test -f /etc/kubernetes/admin.conf',
  }
}
