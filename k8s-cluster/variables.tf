variable "yandex_provider" {
  type = object({
    token     = string
    zone      = string
    folder_id = string
    cloud_id  = string
  })
  description = "YC"
  sensitive   = true
}

variable "service_accounts" {
  type = object({
    kuber = object({
      resource_acc = string
      node_acc     = string
    })
  })
  sensitive = true

  default = {
    kuber = {
      node_acc     = "aje4lqc4ndk2neqaqbuk"
      resource_acc = "aje4lqc4ndk2neqaqbuk"
    }
  }
}

variable "kuber_ip_range" {
  type = object({
    cluster_range = string
    service_range = string
  })

  default = {
    cluster_range = "10.1.0.0/16"
    service_range = "10.2.0.0/16"
  }
}

variable "kuber_version" {
  type    = string
  default = "1.28"
}