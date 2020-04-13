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

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          additional_packages: ['jq', 'kubernetes-cni'],
          cluster_config:      cluster_config,
          init_config:         init_config,
          join_config:         join_config,
          manage_repositories: true,
          repository_url:      'https://foo.bar.com',
          use_proxy:           false,
        }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_class('k8s::shared')
          .with_additional_packages(['jq', 'kubernetes-cni'])
          .with_internet_proxy(nil)
          .with_internet_proxy_port(nil)
          .with_manage_repositories(true)
          .with_repository_url('https://foo.bar.com')
          .with_repository_gpg_key(nil)
          .with_use_proxy(false)
          .with_version('1.15.2')
      }

      it { is_expected.to contain_class('k8s::master::install') }
    end
  end
end
