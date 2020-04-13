# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::shared' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          additional_packages: ['jq', 'kubernetes-cni'],
          manage_repositories: true,
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
      end
    end
  end
end
