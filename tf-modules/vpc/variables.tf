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

variable "cidr_blocks" {
  type = object({
    subnet          = string
    cluster_ingress = string
    cluster_egress  = string
  })
}

variable "route_table_id" {
  type = string
}