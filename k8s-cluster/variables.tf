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
    # master_internal_ip = string
  })

  default = {
    cluster_range = "10.1.0.0/16"
    service_range = "10.2.0.0/16"
    # master_internal_ip = "192.168.10.18"
  }
}

variable "kuber_version" {
  type    = string
  default = "1.28"
}

variable "images" {
  type = object({
    ubuntu_2404         = string
    ubuntu_2204_bastion = string
  })
  description = "Image id's for VM instances"

  default = {
    ubuntu_2404         = "fd8m5hqeuhbtbhltuab4"
    ubuntu_2204_bastion = "fd81vhfcdt7ntmco1qeq"
  }
}

variable "vm_resources" {
  type = map(object({
    cores  = number
    memory = number
    disk   = number
  }))

  default = {
    "vm-bastion" = {
      cores  = 2
      memory = 2
      disk   = 20
    }
  }
}

variable "bastion-ips" {
  type = object({
    internal = string
    external = string
  })
  description = "bastion external reserved ip"

  default = {
    internal = "192.168.10.250"
    external = "158.160.170.196"
  }
}