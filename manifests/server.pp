# @summary Installs and configures a Kubernetes master server
#
# Installs and configures a Kubernetes master server
#
# @example
#   include k8s::server
class k8s::server (
  Array                    $additional_packages,
  Hash                     $cluster_config,
  Boolean                  $cluster_init_master,
  Integer                  $cluster_join_wait,
  String                   $cni_plugin,
  Hash                     $cni_plugin_config,
  Hash                     $init_config,
  Hash                     $join_config,
  Boolean                  $manage_selinux,
  Boolean                  $manage_repositories,
  Boolean                  $manage_sysctl_ipv4_forward,
  String                   $repository_url,
  Enum['master', 'worker'] $role,
  Boolean                  $use_proxy,
  Optional[String]         $internet_proxy      = undef,
  Optional[Integer]        $internet_proxy_port = undef,
  Optional[Hash]           $kubelet_config      = undef,
  Optional[Hash]           $kubeproxy_config    = undef,
  Optional[String]         $repository_gpg_key  = undef,
  ) {

  if $cluster_config['kubernetesVersion'] == false {
    fail('You must specify a Kubernetes version in your $cluster_config parameter.')
  } else {
    $_version = $cluster_config['kubernetesVersion']
  }

  if $join_config['discovery']['bootstrapToken']['apiServerEndpoint'] == false {
    fail('You must specify a bootstrapToken apiServerEndpoint in your $join_config parameter.')
  } else {
    $_apiserver = $join_config['discovery']['bootstrapToken']['apiServerEndpoint']
  }

  ## Provides the common packages/repos/configuration for workers and masters
  class { 'k8s::shared':
    additional_packages        => $additional_packages,
    internet_proxy             => $internet_proxy,
    internet_proxy_port        => $internet_proxy_port,
    manage_selinux             => $manage_selinux,
    manage_repositories        => $manage_repositories,
    manage_sysctl_ipv4_forward => $manage_sysctl_ipv4_forward,
    repository_url             => $repository_url,
    repository_gpg_key         => $repository_gpg_key,
    use_proxy                  => $use_proxy,
    version                    => $_version,
  }
  contain 'k8s::shared'

  if $role == 'master' {
    ## Master-only code here
    class { 'k8s::master::install':
      apiserver           => $_apiserver,
      cluster_config      => $cluster_config,
      cluster_init_master => $cluster_init_master,
      cluster_join_wait   => $cluster_join_wait,
      cni_plugin          => $cni_plugin,
      cni_plugin_config   => $cni_plugin_config,
      init_config         => $init_config,
      internet_proxy      => $internet_proxy,
      internet_proxy_port => $internet_proxy_port,
      join_config         => $join_config,
      kubelet_config      => $kubelet_config,
      kubeproxy_config    => $kubeproxy_config,
      use_proxy           => $use_proxy,
      require             => Class['k8s::shared'],
    }
    contain 'k8s::master::install'
  } else {
    class { 'k8s::worker::install':
      apiserver   => $_apiserver,
      join_config => $join_config,
      require     => Class['k8s::shared'],
    }
    contain 'k8s::worker::install'
  }
}
