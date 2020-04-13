# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include k8s::shared::packages
class k8s::shared::preflight (
  Boolean $manage_selinux,
  Boolean $manage_sysctl_ipv4_forward,
  ) {

  ## Ensuring hostname is set up properly
  file { '/etc/hostname':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $facts['fqdn'],
  }

  exec { 'apply_hostname':
    path    => ['/local/usr/bin', '/usr/bin', '/bin'],
    command => "hostnamectl set-hostname ${facts['fqdn']}",
    unless  => '/bin/test $(hostname) = $(cat /etc/hostname)',
    require => File['/etc/hostname'],
  }

  if $manage_selinux {
    class { 'selinux':
      mode => 'disabled',
    }
  }

  ## Enabling Kernel modules and sysctl parameters
  kmod::load { ['bridge', 'br_netfilter']: }

  if $manage_sysctl_ipv4_forward {
    sysctl { 'net.ipv4.ip_forward':
      ensure  => present,
      value   => '1',
      persist => true,
      silent  => true,
      require => [ Kmod::Load['bridge'], Kmod::Load['br_netfilter'], ],
    }
  }

  sysctl { 'net.ipv4.ip_nonlocal_bind':
    ensure  => present,
    value   => '1',
    persist => true,
    silent  => true,
    require => [ Kmod::Load['bridge'], Kmod::Load['br_netfilter'], ],
  }

  sysctl { 'net.bridge.bridge-nf-call-iptables':
    ensure  => present,
    value   => '1',
    persist => true,
    silent  => true,
    require => [ Kmod::Load['bridge'], Kmod::Load['br_netfilter'], ],
  }

  ## Disabling Firewalld if it exists
  exec { 'disable_firewalld':
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    command => 'systemctl disable firewalld.service',
    onlyif  => 'systemctl is-enabled firewalld.service',
  }

  ## Disabling Swap
  mount { 'swap':
    ensure => 'absent',
    target => '/etc/fstab',
  }

  exec { 'disable_swap':
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    command => 'swapoff -a',
    onlyif  => 'swapon | grep -q -i name',
  }

  ## Legacy from old code
  sysctl { 'fs.inotify.max_user_watches':
    ensure => present,
    value  => '524288',
  }

  exec { 'apply_fs.inotify.max_user_watches':
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    command => "echo '524288' > /proc/sys/fs/inotify/max_user_watches",
    onlyif  => 'test $(cat /proc/sys/fs/inotify/max_user_watches) = 8192',
  }

  exec { 'apply_net.bridge.bridge-nf-call-iptables':
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    command => "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables",
    onlyif  => 'test $(cat /proc/sys/net/bridge/bridge-nf-call-iptables) = 0',
    require => [
      Kmod::Load['bridge'],
      Kmod::Load['br_netfilter'],
    ],
  }
}
