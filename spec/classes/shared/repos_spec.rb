# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::shared::repos' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with hiera parameters' do
        let(:params) do
          {
            repository_url: 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
            use_proxy: false,
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_yumrepo('kubernetes')
            .with_descr('Kubernetes Repository')
            .with_baseurl('https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64')
            .with_proxy(nil)
            .with_gpgkey(%r{packages.cloud.google.com})
            .with_enabled(1)
            .with_gpgcheck(1)
            .with_repo_gpgcheck(1)
        }
      end

      context 'with proxy parameters' do
        let(:params) do
          {
            internet_proxy:      'foo.com',
            internet_proxy_port: '8080',
            repository_url: 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
            use_proxy:           true,
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_yumrepo('kubernetes')
            .with_descr('Kubernetes Repository')
            .with_baseurl('https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64')
            .with_proxy('http://foo.com:8080')
            .with_gpgkey(%r{packages.cloud.google.com})
            .with_enabled(1)
            .with_gpgcheck(1)
            .with_repo_gpgcheck(1)
        }
      end

      ## TODO: Fix the validation errors here
      context 'with custom repository parameters' do
        let(:params) do
          {
            repository_url: 'https://yum.foobar.com',
            repository_gpg_key: 'https://packages.cloud.example.com/yum/doc/yum-key.gpg',
            use_proxy: false,
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_yumrepo('kubernetes')
            .with_descr('Kubernetes Repository')
            .with_baseurl('https://yum.foobar.com')
            .with_proxy(nil)
            .with_gpgkey(%r{example.com})
            .with_enabled(1)
            .with_gpgcheck(1)
            .with_repo_gpgcheck(1)
        }
      end
    end
  end
end
