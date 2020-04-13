# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include k8s::shared::repos
class k8s::shared::repos (
  String            $repository_url,
  Boolean           $use_proxy,
  Optional[String]  $internet_proxy      = undef,
  Optional[Integer] $internet_proxy_port = undef,
  Optional[String]  $repository_gpg_key  = undef,
  ) {

  if $repository_gpg_key {
    $_repository_gpg_key = $repository_gpg_key
  } else {
    $_repository_gpg_key = 'https://packages.cloud.google.com/yum/doc/yum-key.gpg
    https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg'
  }

  case $use_proxy {
    true: {
      ## TODO: Concatenate this at the entry to the module because this is dumb
      $_proxy = "http://${internet_proxy}:${internet_proxy_port}"
    }
    default: {
      $_proxy = undef
    }
  }

  yumrepo { 'kubernetes':
    descr         => 'Kubernetes Repository',
    baseurl       => $repository_url,
    proxy         => $_proxy,
    gpgkey        => $_repository_gpg_key,
    enabled       => 1,
    gpgcheck      => 1,
    repo_gpgcheck => 1,
  }
}
