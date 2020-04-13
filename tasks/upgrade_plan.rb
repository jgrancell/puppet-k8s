#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

# Puppet Task Name: upgrade_plan

def upgrade_plan
  cmd = ['kubeadm', 'upgrade', 'plan']
  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, _("stderr: '%{stderr}'" % { stderr: stderr }) if status != 0
  { status: stdout.strip }
end

begin
  result = upgrade_plan
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
