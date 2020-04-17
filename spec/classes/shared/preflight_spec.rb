# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::shared::preflight' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with hiera parameters' do
        let(:params) do
          {
            manage_selinux:                 true,
            manage_sysctl_ipv4_forward:     true,
            manage_sysctl_ip_nonlocal_bind: true,
          }
        end

        it { is_expected.to compile }
      end
    end
  end
end
