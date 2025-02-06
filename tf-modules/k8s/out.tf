output "cluster_ipv4_range" {
  value = yandex_kubernetes_cluster.my-zonal-cluster.cluster_ipv4_range
}

output "service_ipv4_range" {
  value = yandex_kubernetes_cluster.my-zonal-cluster.service_ipv4_range
}