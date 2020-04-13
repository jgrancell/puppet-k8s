# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::shared::filesystem' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with hiera parameters' do
        let(:params) do
          {
            maxpods: 110,
          }
        end

        it { is_expected.to compile }

        it { is_expected.to contain_file('/var/lib/kubelet').with_ensure('directory') }
        it { is_expected.to contain_file('/var/lib/kubelet/kubeadm-flags.env').with_content(%r{cgroup-driver=cgroupfs}) }
        it { is_expected.to contain_file_line('protect_critical_master_pods').with_line(%r{ExperimentalCriticalPodAnnotation=true}) }
        it { is_expected.to contain_file('/var/lib/kubelet/config.yaml').with_content(%r{maxPods: 110}) }
      end
    end
  end
end
