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