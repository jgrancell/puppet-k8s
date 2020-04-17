# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::server' do
  cluster_config = {
    'apiVersion'           => 'kubeadm.k8s.io/v1beta2',
    'kind'                 => 'ClusterConfiguration',
    'controlPlaneEndpoint' => 'test.example.com:6443',
    'imageRepository'      => 'k8s.gcr.io',
    'kubernetesVersion'    => 'v1.15.2',
    'certificatesDir'      => '/etc/kubernetes/pki',
    'clusterName'          => 'kubernetes',
    'etcd'                 => {
      'local' => {
        'imageRepository' => 'k8s.gcr.io',
        'imageTag'        => '3.3.10',
        'dataDir'         => '/var/lib/etcd',
      },
    },
    'networking' => {
      'serviceSubnet' => '10.96.0.0/12',
      'podSubnet'     => '10.229.0.0/16',
      'dnsDomain'     => 'cluster.local',
    },
    'apiServer' => {
      'extraArgs' => {
        'authorization-mode'       => 'Node,RBAC',
        'endpoint-reconciler-type' => 'lease',
      },
    },
  }

  init_config = {
    'apiVersion'      => 'kubeadm.k8s.io/v1beta2',
    'kind'            => 'InitConfiguration',
    'bootstrapTokens' => [
      {
        'token' => '9a08jv.c0izixklcxtmnze7',
        'description' => 'kubeadm bootstrap token',
        'ttl' => '24h',
      },
    ],
    'nodeRegistration' => {
      'kubeletExtraArgs' => {
        'cgroup-driver'  => 'systemd',
        'cni-bin-dir'    => '/opt/cni/bin',
        'cni-conf-dir'   => '/etc/cni/net.d',
        'network-plugin' => 'cni',
        'feature-gates'  => 'PodPriority=true,ExperimentalCriticalPodAnnotation=true',
      },
    },
    'certificateKey' => 'e6a2eb8581237ab72a4f494f30285ec12a9694d750b9785706a83bfcbbbd2204',
  }

  join_config = {
    'apiVersion' => 'kubeadm.k8s.io/v1beta2',
    'kind'       => 'JoinConfiguration',
    'caCertPath' => '/etc/kubernetes/pki/ca.crt',
    'discovery'  => {
      'bootstrapToken' => {
        'token'             => '9a08jv.c0izixklcxtmnze7',
        'apiServerEndpoint' => '%{trusted.certname}:6443',
        'caCertHashes'      => [
          'sha256:a09036f52ed22fd61448a5c69cf3f16343d8b0fb1c44cf67b104ce45a7cc07d9',
        ],
        'unsafeSkipCAVerification' => false,
        'controlPlane'             => {
          'certificateKey' => 'e6a2eb8581237ab72a4f494f30285ec12a9694d750b9785706a83bfcbbbd2204',
        },
      },
    },
  }

  cni_config = {
    'ipv4pool_cidr' => '10.229.0.0/16',
    'ipv4pool_ipip' => 'Off',
    'version'       => '3.13.1',
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          additional_packages:            ['jq', 'kubernetes-cni'],
          cluster_config:                 cluster_config,
          cluster_init_master:            true,
          cluster_join_wait:              60,
          cni_plugin:                     'calico',
          cni_plugin_config:              cni_config,
          init_config:                    init_config,
          join_config:                    join_config,
          manage_selinux:                 true,
          manage_repositories:            true,
          manage_sysctl_ipv4_forward:     true,
          manage_sysctl_ip_nonlocal_bind: true,
          repository_url:                 'https://foo.bar.com',
          role:                           'master',
          use_proxy:                      false,
        }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_class('k8s::shared')
          .with_additional_packages(['jq', 'kubernetes-cni'])
          .with_internet_proxy(nil)
          .with_internet_proxy_port(nil)
          .with_manage_selinux(true)
          .with_manage_repositories(true)
          .with_manage_sysctl_ipv4_forward(true)
          .with_manage_sysctl_ip_nonlocal_bind(true)
          .with_repository_url('https://foo.bar.com')
          .with_repository_gpg_key(nil)
          .with_use_proxy(false)
          .with_version('v1.15.2')
      }

      it {
        is_expected.to contain_class('k8s::master::install')
          .with_apiserver('%{trusted.certname}:6443')
          .with_cluster_config(cluster_config)
          .with_cluster_init_master(true)
          .with_cluster_join_wait(60)
          .with_cni_plugin('calico')
          .with_cni_plugin_config(cni_config)
          .with_init_config(init_config)
          .with_internet_proxy(nil)
          .with_internet_proxy_port(nil)
          .with_join_config(join_config)
          .with_kubelet_config(nil)
          .with_kubeproxy_config(nil)
          .with_use_proxy(false)
          .with_require('Class[K8s::Shared]')
      }

      it { is_expected.to contain_class('k8s::master::install') }
    end
  end
end
