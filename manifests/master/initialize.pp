# @summary Initializes a Kubernetes control plane
#
# Initializes a Kubernetes control plane
#
# @example
#   include k8s::master::initialize
class k8s::master::initialize {

  ## TODO: Add more unless checking here -- very fragile
  exec { 'kubeadm-init':
    command   => 'kubeadm init --config /etc/kubernetes/kubeadm/master.yaml --upload-certs',
    logoutput => true,
    path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    unless    => 'test -f /etc/kubernetes/admin.conf',
  }
}
