# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include k8s::shared::networking
class k8s::shared::networking::calico (
  String            $apiserver,
  Boolean           $cluster_init_master,
  Hash              $config_hash,
  Boolean           $use_proxy,
  Optional[String]  $internet_proxy      = undef,
  Optional[Integer] $internet_proxy_port = undef,
  ) {

  File {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }

  ## Config hash validation
  if $config_hash['version'] == undef {
    err('k8s::shared::networking::calico::config_hash must include the key "version".')
  } else {
    $_version = $config_hash['version']
  }

  if $config_hash['ipv4pool_cidr'] == undef {
    err('k8s::shared::networking::calico::config_hash must include the key "pod_network_cidr".')
  } else {
    $_ipv4pool_cidr = $config_hash['ipv4pool_cidr']
  }

  if $config_hash['ipv4pool_ipip'] == undef {
    err('k8s::shared::networking::calico::config_hash must include the key "ipv4pool_ipip".')
  } else {
    $_ipv4pool_ipip = $config_hash['ipv4pool_ipip']
  }

  $_binary_name = "calicoctl-${_version}"

  case $use_proxy {
    true: {
      ## TODO: Concatenate this at the entry to the module because this is dumb
      $_proxy = "http://${internet_proxy}:${internet_proxy_port}"
    }
    default: {
      $_proxy = undef
    }
  }

  archive { "/usr/local/bin/calicoctl-${_binary_name}":
    source       => "https://github.com/projectcalico/calicoctl/releases/download/v${_version}/calicoctl",
    extract      => false,
    proxy_server => $_proxy,
  }

  file { "/usr/local/bin/${_binary_name}":
    mode    => '0755',
    require => Archive["/usr/local/bin/calicoctl-${_binary_name}"],
  }

  file { '/usr/local/bin/calicoctl':
    ensure  => link,
    target  => "/usr/local/bin/${_binary_name}",
    require => File["/usr/local/bin/${_binary_name}"]
  }

  file { ['/etc/calico', '/etc/cni', '/etc/cni/net.d']:
    ensure => directory,
    mode   => '0750',
  }

  ## TODO: Add appropriate params
  if $config_hash['cni_config'] != undef {
    file { '/etc/cni/net.d/10-calico.conflist':
      replace => false,
      content => to_json($config_hash['cni_config']),
    }
  }

  ## Add kubectl validate command here
  file { '/etc/calico/calico.yaml':
    content => epp("k8s/shared/networking/calico/calico-${_version}.yaml", {
      'ipv4pool_cidr' => $_ipv4pool_cidr,
      'ipv4pool_ipip' => $_ipv4pool_ipip,
    }),
  }

  if $cluster_init_master {
    http_conn_validator { "https://${apiserver}":
      use_ssl       => true,
      verify_peer   => false,
      try_sleep     => 60,
      timeout       => $cluster_join_wait,
      expected_code => 403,
      before        => Exec['install_calico'],
    }

    exec { 'install_calico':
      command     => 'kubectl apply -f /etc/calico/calico.yaml',
      environment => 'KUBECONFIG=/etc/kubernetes/admin.conf',
      logoutput   => true,
      path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin', '/usr/local/bin'],
      refreshonly =>  true,
      tries       => 15,
      try_sleep   => 2,
      subscribe   => File['/etc/calico/calico.yaml'],
      unless      => 'test -f /etc/cni/net.d/calico-kubeconfig',
    }
  }


}
