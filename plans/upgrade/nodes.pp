plan k8s::upgrade::nodes (
  TargetSpec $targets,
  Variant[Pattern[
    /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/,
    /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  ]] $kubectl_host,
  Pattern[/v\d+\.\d+\.\d+/] $version,
) {
  $nodes = get_targets($targets).map |$n| { $n.name }
  $nodes.each |$index, $node| {
    run_task('k8s::install_kubeadm', $node, "Installing kubeadm ${version}", 'version' => $version)
    run_task('k8s::drain_node', $kubectl_host, "Executing drain of ${node}", 'node' => $node)
    run_task('k8s::upgrade_node', $node, "Running node upgrade to ${version}")
    run_task('k8s::install_kubectl', $node, "Installing kubectl ${version}", 'version' => $version)
    run_task('k8s::install_kubelet', $node, "Installing kubelet ${version}", 'version' => $version)
    run_task('k8s::restart_kubelet', $node, "Restarting the kubelet service")
    run_task('k8s::uncordon_node', $kubectl_host, "Executing uncordon of ${node}", 'node' => $node)
  }
}
