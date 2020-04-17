# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::shared' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          additional_packages: ['jq', 'kubernetes-cni'],
          manage_selinux: true,
          manage_repositories: true,
          manage_sysctl_ipv4_forward: true,
          manage_sysctl_ip_nonlocal_bind: true,
          repository_url:      'https://test.example.com',
          use_proxy:           false,
          version:             '1.15.2',
        }
      end

      context 'with hiera parameters' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('k8s::shared::preflight') }
        it { is_expected.to contain_class('k8s::shared::repos') }

        it { is_expected.to contain_class('k8s::shared::packages') }
        it { is_expected.to contain_class('k8s::shared::services') }
      end
    end
  end
end
