# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'gitlab class' do
  let(:manifest) do
    <<-MANIFEST
      class { 'k8s::server':
        type => 'master',
      }
    MANIFEST
  end

  it 'must run without errors' do
    result = apply_manifest(manifest, catch_failures: true)
    expect(result.exit_code).to eq 2
  end

  it 'must run a second time idempotently' do
    secondary = apply_manifest(manifest, catch_failures: true)
    expect(secondary.exit_code).to eq 0
  end
end
