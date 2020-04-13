# frozen_string_literal: true

require 'spec_helper'

describe 'k8s::shared::preflight' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with hiera parameters' do
        let(:params) do
          {}
        end

        it { is_expected.to compile }
      end
    end
  end
end
