#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

# Puppet Task Name: create_join_command

def create_join_command(control_plane, certificate_key)
  if control_plane && (certificate_key.nil? || certificate_key.empty?)
    raise Puppet::Error, 'control plane join command requested but no certificate_key was supplied'
  end
  cmd = ['kubeadm', 'token', 'create', '--print-join-command']
  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, _("stderr: '%{stderr}'" % { stderr: stderr }) if status != 0
  join_cmd = stdout.strip
  if control_plane
    join_cmd += " --certificate-key #{certificate_key} --control-plane"
  end
  { join_command: join_cmd }
end

params = JSON.parse(STDIN.read)
control_plane = params['control_plane']
certificate_key = params['certificate_key']

begin
  result = create_join_command(control_plane, certificate_key)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
