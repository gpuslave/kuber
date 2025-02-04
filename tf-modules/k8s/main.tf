terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }

  required_version = "~>1.10.5"
}

resource "yandex_kubernetes_cluster" "my-zonal-cluster" {
  name        = "gpuslave-cluster"
  description = "k8s for testing"

  network_id = var.vpc.network_id

  master {
    version = var.kuber_version
    zonal {
      zone      = var.vpc.subnet_zone
      subnet_id = var.vpc.subnet_id
    }

    public_ip = true

    security_group_ids = [var.vpc.security_group_id]


    maintenance_policy {
      auto_upgrade = true
    }

    master_logging {
      enabled   = true
      folder_id = var.yandex_provider.folder_id

      audit_enabled              = true
      events_enabled             = true
      cluster_autoscaler_enabled = true
      kube_apiserver_enabled     = true
    }
  }

  cluster_ipv4_range = var.kuber_ip_range.cluster_range
  service_ipv4_range = var.kuber_ip_range.service_range

  service_account_id      = var.kuber_service_accounts.resource_acc
  node_service_account_id = var.kuber_service_accounts.node_acc

  release_channel = "STABLE"
}

resource "yandex_kubernetes_node_group" "my-node-group" {
  cluster_id  = yandex_kubernetes_cluster.my-zonal-cluster.id
  name        = "new-cluster"
  description = "test node group"
  version     = var.kuber_version

  instance_template {
    platform_id = var.kuber_instance_template.platform_id

    network_interface {
      nat                = var.kuber_instance_template.network_interface.nat
      subnet_ids         = var.kuber_instance_template.network_interface.subnet_ids
      security_group_ids = var.kuber_instance_template.network_interface.security_group_ids
    }

    resources {
      memory = var.kuber_instance_template.resources.memory
      cores  = var.kuber_instance_template.resources.cores
    }

    boot_disk {
      type = var.kuber_instance_template.boot_disk.type
      size = var.kuber_instance_template.boot_disk.size
    }

    scheduling_policy {
      preemptible = var.kuber_instance_template.scheduling_policy.preemptible
    }

    container_runtime {
      type = var.kuber_instance_template.container_runtime.type
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  maintenance_policy {
    auto_repair  = true
    auto_upgrade = true
  }

  allocation_policy {
    location {
      zone = var.yandex_provider.zone
    }
  }

}