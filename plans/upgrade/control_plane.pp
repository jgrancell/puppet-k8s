plan k8s::upgrade::control_plane (
  TargetSpec $targets,
  Pattern[/v\d+\.\d+\.\d+/] $version,
) {
  $nodes = get_targets($targets).map |$n| { $n.name }
  $nodes.each |$index, $node| {
    run_task('k8s::install_kubeadm', $node, "Installing kubeadm ${version}", 'version' => $version)
    run_task('k8s::drain_node', $node, 'Executing drain', 'node' => $node)
    if $index == 0 {
      run_task('k8s::upgrade_plan', $node, "Planning upgrade to ${version}")
      run_task('k8s::upgrade_apply', $node, "Applying upgrade to ${version}", 'version' => $version)
    } else {
      run_task('k8s::upgrade_node', $node, "Running node upgrade to ${version}")
    }
    run_task('k8s::uncordon_node', $node, 'Executing uncordon', 'node' => $node)
    run_task('k8s::install_kubectl', $node, "Installing kubectl ${version}", 'version' => $version)
    run_task('k8s::install_kubelet', $node, "Installing kubelet ${version}", 'version' => $version)
    run_task('k8s::restart_kubelet', $node, 'Restarting the kubelet service')
  }
}
