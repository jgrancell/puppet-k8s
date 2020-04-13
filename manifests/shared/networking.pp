# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include k8s::shared::networking
class k8s::shared::networking (
  String            $apiserver,
  Boolean           $cluster_init_master,
  Enum['calico']    $cni_plugin,
  Hash              $cni_plugin_config,
  Boolean           $use_proxy,
  Optional[String]  $internet_proxy      = undef,
  Optional[Integer] $internet_proxy_port = undef,
  ) {

  class { "k8s::shared::networking::${cni_plugin}":
    apiserver           => $apiserver,
    cluster_init_master => $cluster_init_master,
    config_hash         => $cni_plugin_config,
    use_proxy           => $use_proxy,
    internet_proxy      => $internet_proxy,
    internet_proxy_port => $internet_proxy_port,
  }
  contain "k8s::shared::networking::${cni_plugin}"
}
