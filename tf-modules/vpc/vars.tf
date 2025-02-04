variable "yandex_provider" {
  type = object({
    zone      = string
    folder_id = string
    cloud_id  = string
  })
  description = "YC"
}

variable "cidr_blocks" {
  type = object({
    subnet          = string
    cluster_ingress = string
    cluster_egress  = string
  })
}