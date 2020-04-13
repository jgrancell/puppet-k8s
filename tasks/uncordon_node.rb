#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

# Puppet Task Name: uncordon_node

def uncordon_node(node)
  cmd = ['kubectl', 'uncordon', node]
  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, _("stderr: '%{stderr}'" % { stderr: stderr }) if status != 0
  { status: stdout.strip }
end

params = JSON.parse(STDIN.read)
node = params['node'] || %x[hostname -f].chomp

begin
  result = uncordon_node(node)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
