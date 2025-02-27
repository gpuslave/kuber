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

variable "gateway_routing" {
  type    = bool
  default = false
}

variable "rt_name" {
  type = string
}

variable "network_id" {
  type = string
}

variable "static_routes" {
  type = list(object({
    destination_prefix = string
    next_hop_address   = optional(string)
  }))
}