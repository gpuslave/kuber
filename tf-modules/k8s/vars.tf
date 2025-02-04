variable "yandex_provider" {
  type = object({
    zone      = string
    folder_id = string
    cloud_id  = string
  })
  description = "YC"
}

variable "kuber_service_accounts" {
  type = object({
    resource_acc = string
    node_acc     = string
  })
}

variable "kuber_ip_range" {
  type = object({
    cluster_range = string
    service_range = string
  })
}

variable "kuber_version" {
  type = string
}

variable "vpc" {
  type = object({
    network_id        = string
    subnet_id         = string
    subnet_zone       = string
    security_group_id = string
  })
}

variable "kuber_instance_template" {
  type = object({
    platform_id = string

    network_interface = object({
      nat                = bool
      subnet_ids         = list(string)
      security_group_ids = list(string)
    })

    resources = object({
      memory = number
      cores  = number
    })

    boot_disk = object({
      type = string
      size = number
    })

    scheduling_policy = object({
      preemptible = bool
    })

    container_runtime = object({
      type = string
    })
  })
}