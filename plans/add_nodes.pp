plan k8s::add_nodes (
  TargetSpec $targets,
  Variant[Pattern[
    /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/,
    /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  ]] $kubectl_host,
  Boolean $control_plane = false,
) {
  if $control_plane {
    $certs_res = run_task('k8s::upload_certs', $kubectl_host, 'Uploading certs to cluster').first
    $key = $certs_res['certificate_key']
    $cp  = true
  } else {
    $key = undef
    $cp  = false
  }
  $cmd_res = run_task('k8s::create_join_command', $kubectl_host, 'Creating node join command',
                      'control_plane' => $cp, 'certificate_key' => $key).first
  $join_command = $cmd_res['join_command']
  $nodes = get_targets($targets).map |$n| { $n.name }
  $nodes.each |$node| {
    run_task('k8s::join_node', $node, 'Running join command', 'join_command' => $join_command)
  }
}
