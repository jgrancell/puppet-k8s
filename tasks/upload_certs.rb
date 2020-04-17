#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

# Puppet Task Name: upload_certs

def upload_certs(certificate_key)
  cmd = ['kubeadm', 'init', 'phase', 'upload-certs', '--upload-certs']
  cmd += ["--certificate-key=#{certificate_key}"] unless certificate_key.nil?
  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, _("stderr: '%{stderr}'" % { stderr: stderr }) if status != 0
  key = stdout.strip.match(/Using certificate key:\n(\h+)$/i)[1]
  { certificate_key: key }
end

params = JSON.parse(STDIN.read)
certificate_key = params['certificate_key']

begin
  result = upload_certs(certificate_key)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
