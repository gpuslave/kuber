variable "yandex_provider" {
  type = object({
    token     = string
    zone      = string
    folder_id = string
    cloud_id  = string
  })
  description = "YC config"
  sensitive   = true
}

variable "kuber_service_accounts" {
  type = object({
    resource_acc = string
    node_acc     = string
  })
  sensitive = true
}

variable "kuber_ip_range" {
  type = object({
    cluster_range = string
    service_range = string
    node_mask     = number
    # master_internal_ip = string
  })
}

variable "kuber_version" {
  type    = string
  default = "1.28"
}

variable "cluster_name" {
  type    = string
  default = "default-cluster-name"
}

variable "vpc" {
  type = object({
    network_id        = string
    subnet_id         = string
    subnet_zone       = string
    security_group_id = string
  })
}

# variable "kuber_instance_template" {
#   type = object({
#     platform_id = string

#     network_interface = object({
#       nat                = bool
#       subnet_ids         = list(string)
#       security_group_ids = list(string)
#     })

#     resources = object({
#       memory = number
#       cores  = number
#     })

#     boot_disk = object({
#       type = string
#       size = number
#     })

#     scheduling_policy = object({
#       preemptible = bool
#     })

#     container_runtime = object({
#       type = string
#     })
#   })
# }

variable "node_groups" {
  description = "Map of node group configurations"

  type = map(object({
    name        = string
    description = optional(string, "Managed node group")
    version     = optional(string) # Defaults to kuber_version if not specified

    platform_id = string

    network_interface = object({
      nat                = bool
      subnet_ids         = list(string)
      security_group_ids = list(string)
    })

    resources = object({
      memory = optional(number, 4)
      cores  = optional(number, 2)
    })

    boot_disk = object({
      type = optional(string, "network-ssd")
      size = optional(number, "64")
    })

    scheduling_policy = object({
      preemptible = optional(bool, false)
    })

    allocation_policy = object({
      location = object({
        zone = string
      })
    })

    scale_policy = optional(object({
      fixed_scale = object({
        size = optional(number, 1)
      })
      }),
    { fixed_scale = { size = 1 } })
  }))
}