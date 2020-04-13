# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::shared::packages' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      additional_packages = ['jq', 'kubernetes-cni']

      context 'with hiera parameters' do
        let(:params) do
          {
            additional_packages: additional_packages,
            version: '1.15.2',
          }
        end

        it { is_expected.to compile }

        it { is_expected.to contain_package('kubectl').with_ensure('1.15.2-0') }
        it { is_expected.to contain_package('kubelet').with_ensure('1.15.2-0').with_require('Package[kubectl]') }
        it { is_expected.to contain_package('kubeadm').with_ensure('1.15.2-0').with_require('Package[kubelet]') }

        additional_packages.each do |package|
          it {
            is_expected.to contain_package(package)
              .with_ensure('present')
              .with_require('Package[kubeadm]')
          }
        end
      end
    end
  end
end
