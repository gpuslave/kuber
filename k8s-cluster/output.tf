output "cluster_ipv4_range" {
  value = module.k8s-cluster.cluster_ipv4_range
}

output "service_ipv4_range" {
  value = module.k8s-cluster.service_ipv4_range
}