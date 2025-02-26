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
  name = var.cluster_name

  network_id = var.vpc.network_id

  master {
    version = var.kuber_version
    zonal {
      zone      = var.vpc.subnet_zone
      subnet_id = var.vpc.subnet_id
    }

    public_ip = false

    # NOTE: how to know this everytime? 
    # yc managed-kubernetes cluster list # provides master internal IP
    # internal_v4_address = var.kuber_ip_range.master_internal_ip

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

  cluster_ipv4_range       = var.kuber_ip_range.cluster_range
  service_ipv4_range       = var.kuber_ip_range.service_range
  node_ipv4_cidr_mask_size = var.kuber_ip_range.node_mask

  # network_policy_provider = "CALICO"

  network_implementation { 
    cilium {} 
  }

  service_account_id      = var.kuber_service_accounts.resource_acc
  node_service_account_id = var.kuber_service_accounts.node_acc

  release_channel = "STABLE"
}


resource "yandex_kubernetes_node_group" "node_groups" {
  for_each = var.node_groups

  cluster_id  = yandex_kubernetes_cluster.my-zonal-cluster.id
  name        = each.value.name
  description = each.value.description
  version     = each.value.version != null ? each.value.version : var.kuber_version

  instance_template {
    platform_id = each.value.platform_id

    network_interface {
      nat                = each.value.network_interface.nat
      subnet_ids         = each.value.network_interface.subnet_ids
      security_group_ids = each.value.network_interface.security_group_ids
    }

    resources {
      memory = each.value.resources.memory
      cores  = each.value.resources.cores
    }

    boot_disk {
      type = each.value.boot_disk.type
      size = each.value.boot_disk.size
    }

    scheduling_policy {
      preemptible = each.value.scheduling_policy.preemptible
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = each.value.scale_policy.fixed_scale.size
    }
  }

  maintenance_policy {
    auto_repair  = true
    auto_upgrade = true
  }

  allocation_policy {
    location {
      zone = var.vpc.subnet_zone
    }
  }
}