# @summary Installs a Kubernetes master
#
# Installs all necessary components for a Kubernetes master server
#
# @example
#   include k8s::master::install
class k8s::master::install (
  String            $apiserver,
  Hash              $cluster_config,
  Boolean           $cluster_init_master,
  Integer           $cluster_join_wait,
  String            $cni_plugin,
  Hash              $cni_plugin_config,
  Hash              $init_config,
  Hash              $join_config,
  Boolean           $run_kubeadm,
  Boolean           $use_proxy,
  Optional[String]  $internet_proxy      = undef,
  Optional[Integer] $internet_proxy_port = undef,
  Optional[Hash]    $kubelet_config      = undef,
  Optional[Hash]    $kubeproxy_config    = undef,
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

  file { '/etc/kubernetes/kubeadm/cluster-stub.yaml':
    content => to_yaml($cluster_config),
    notify  => Exec['generate-master-yaml'],
  }

  file { '/etc/kubernetes/kubeadm/init-stub.yaml':
    content => to_yaml($init_config),
    notify  => Exec['generate-master-yaml'],
  }

  file { '/etc/kubernetes/kubeadm/join-stub.yaml':
    content => to_yaml($join_config),
    notify  => Exec['generate-master-yaml'],
  }

  if $kubelet_config {
    file { '/etc/kubernetes/kubeadm/kubelet-stub.yaml':
      content => to_yaml($kubelet_config),
      notify  => Exec['generate-master-yaml'],
    }
  }

  if $kubeproxy_config {
    file { '/etc/kubernetes/kubeadm/kubeproxy-stub.yaml':
      content => to_yaml($kubeproxy_config),
      notify  => Exec['generate-master-yaml'],
    }
  }

  exec { 'generate-master-yaml':
    command     => 'cat /etc/kubernetes/kubeadm/*-stub.yaml > /etc/kubernetes/kubeadm/master.yaml',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
  }

  if $run_kubeadm {
    if ! $cluster_init_master {
      # Checking for connectivity to the cluster init master prior to joining
      http_conn_validator { "https://${apiserver}":
        use_ssl       => true,
        verify_peer   => false,
        try_sleep     => 60,
        timeout       => $cluster_join_wait,
        expected_code => 403,
      }

      class { 'k8s::master::join':
        apiserver => $apiserver,
        before    => Class['k8s::shared::networking'],
        require   => [Exec['generate-master-yaml'], Http_conn_validator["https://${apiserver}"]],
      }
    } else {
      class { 'k8s::master::initialize':
        before  => Class['k8s::shared::networking'],
        require => Exec['generate-master-yaml'],
      }
    }

    # Add calico functionality
    class { 'k8s::shared::networking':
      apiserver           => $apiserver,
      cluster_init_master => $cluster_init_master,
      cni_plugin          => $cni_plugin,
      cni_plugin_config   => $cni_plugin_config,
      use_proxy           => $use_proxy,
      internet_proxy      => $internet_proxy,
      internet_proxy_port => $internet_proxy_port,
    }

    file { '/root/.kube':
      ensure  => directory,
      mode    => '0700',
      require => Class['k8s::shared::networking'],
    }

    file { '/root/.kube/config':
      ensure => link,
      target => '/etc/kubernetes/admin.conf',
    }
  }
}
