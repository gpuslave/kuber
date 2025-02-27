variable "external_vpc" {
  type = object({
    network_name = string

    subnet = object({
      name       = string
      cidr       = string
      bastion_ip = string
    })

    sg = object({
      name         = string
      ingress_cidr = optional(string, "0.0.0.0/0")
    })
  })
}

variable "internal_vpc" {
  type = object({
    subnet_id  = string
    bastion_ip = string
    sg_id      = string
    network_id = string
  })
}

variable "resources" {
  type = object({
    vm = object({
      name   = string
      cores  = optional(number, 2)
      memory = optional(number, 4)
    })

    disk = object({
      name     = string
      type     = optional(string, "network-hdd")
      size     = number
      image_id = optional(string, "fd81vhfcdt7ntmco1qeq")
    })
  })
}

variable "cloud_init" {
  type = string
}

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