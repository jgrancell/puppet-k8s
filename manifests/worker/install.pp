# @summary Installs a Kubernetes worker
#
# Installs all necessary components for a Kubernetes worker server
#
# @example
#   include k8s::worker::install
class k8s::worker::install (
  String $apiserver,
  Hash   $join_config,
  ) {

  File {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
  }

  file { '/etc/kubernetes':
    ensure => directory,
    mode   => '0750',
  }

  file { '/etc/kubernetes/kubeadm':
    ensure => directory,
    mode   => '0700',
  }

  file { '/etc/kubernetes/kubeadm/join-stub.yaml':
    content => to_yaml($join_config),
    notify  => Exec['generate-worker-yaml'],
  }


  exec { 'generate-worker-yaml':
    command     => 'cat /etc/kubernetes/kubeadm/*-stub.yaml > /etc/kubernetes/kubeadm/worker.yaml',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
  }

  exec { 'kubeadm-join':
    command   => "kubeadm join --config /etc/kubernetes/kubeadm/worker.yaml ${apiserver}",
    logoutput => true,
    path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    unless    => 'test -f /etc/kubernetes/admin.conf',
    require   => Exec['generate-worker-yaml'],
  }

  # TODO: Add upgrade functionality
}
