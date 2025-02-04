variable "yandex_provider" {
  type = object({
    zone      = string
    folder_id = string
    cloud_id  = string
  })
  description = "YC"
}

variable "service_accounts" {
  type = object({
    kuber = object({
      resource_acc = string
      node_acc     = string
    })
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