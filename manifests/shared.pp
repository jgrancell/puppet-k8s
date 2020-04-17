# @summary Configures shared Kubernetes resources
#
# Installs and configures all items in common between a Kubernetes master
# and worker.
#
# @example
#   class { 'k8s::shared':
#     version => '1.16.0',
#   }
class k8s::shared (
  Array             $additional_packages,
  Boolean           $manage_selinux,
  Boolean           $manage_repositories,
  Boolean           $manage_sysctl_ipv4_forward,
  Boolean           $manage_sysctl_ip_nonlocal_bind,
  String            $repository_url,
  Boolean           $use_proxy,
  String            $version,
  Optional[String]  $internet_proxy      = undef,
  Optional[Integer] $internet_proxy_port = undef,
  Optional[String]  $repository_gpg_key  = undef,
  ) {

  class { 'k8s::shared::preflight':
    manage_selinux                 => $manage_selinux,
    manage_sysctl_ipv4_forward     => $manage_sysctl_ipv4_forward,
    manage_sysctl_ip_nonlocal_bind => $manage_sysctl_ip_nonlocal_bind,
  }
  contain 'k8s::shared::preflight'

  if $manage_repositories {
    class { 'k8s::shared::repos':
      internet_proxy      => $internet_proxy,
      internet_proxy_port => $internet_proxy_port,
      repository_url      => $repository_url,
      repository_gpg_key  => $repository_gpg_key,
      use_proxy           => $use_proxy,
    }
    contain 'k8s::shared::repos'
  }

  class { 'k8s::shared::packages':
    additional_packages => $additional_packages,
    version             => $version,
  }
  contain 'k8s::shared::packages'

  class { 'k8s::shared::services': }
  contain 'k8s::shared::services'

  if defined('Class[k8s::shared::repos]') {
    Class['k8s::shared::repos']
    -> Class['k8s::shared::packages']
  }

  Class['k8s::shared::preflight']
  -> Class['k8s::shared::packages']
  -> Class['k8s::shared::services']
}
