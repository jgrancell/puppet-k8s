#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

# Puppet Task Name: install_kubelet

def install_kubelet(version)
  cmd = ['yum', 'install', '-y', "kubelet-#{version}-0"]
  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, _("stderr: '%{stderr}'" % { stderr: stderr }) if status != 0
  { status: stdout.strip }
end

params = JSON.parse(STDIN.read)
version = params['version'][1..-1]

begin
  result = install_kubelet(version)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
