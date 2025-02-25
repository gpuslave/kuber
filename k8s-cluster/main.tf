terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "my-new-bucket-gpuslave"
    region = "ru-central1"
    key    = "states/tf-kuber.tfstate"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

  required_version = "~> 1.10.5"
}

provider "yandex" {
  token     = var.yandex_provider.token
  zone      = var.yandex_provider.zone
  folder_id = var.yandex_provider.folder_id
  cloud_id  = var.yandex_provider.cloud_id
}

module "yc-vpc" {
  source = "../tf-modules/vpc"

  yandex_provider = var.yandex_provider

  # TODO: make proper ing/eg with encapsulation
  cidr_blocks = {
    cluster_egress  = "0.0.0.0/0"
    cluster_ingress = "0.0.0.0/0"
    subnet          = "192.168.10.0/24"
  }
}

module "k8s-cluster" {
  source = "../tf-modules/k8s"

  yandex_provider = var.yandex_provider

  kuber_service_accounts = var.service_accounts.kuber

  kuber_ip_range = var.kuber_ip_range

  kuber_version = var.kuber_version

  cluster_name = "gpuslave-cluster"

  vpc = {
    network_id        = module.yc-vpc.network_id
    subnet_id         = module.yc-vpc.subnet_id
    subnet_zone       = module.yc-vpc.subnet_zone
    security_group_id = module.yc-vpc.security_group_id
  }

  node_groups = {
    # General purpose node group
    default = {
      name        = "default-pool"
      description = "General purpose node group"
      platform_id = "standard-v3"

      network_interface = {
        nat                = false
        subnet_ids         = [module.yc-vpc.subnet_id]
        security_group_ids = [module.yc-vpc.security_group_id]
      }

      resources = {
        memory = 4
        cores  = 2
      }

      boot_disk = {
        type = "network-ssd"
        size = 64
      }

      scheduling_policy = {
        preemptible = false
      }

      allocation_policy = { location = { zone = module.yc-vpc.subnet_zone } }

      # scale_policy = {
      #   fixed_scale = {
      #     size = 1
      #   }
      # }
    }
    # ,
    # High memory node group
    # memory_optimized = {
    #   name        = "memory-pool"
    #   description = "Memory optimized node group"
    #   platform_id = "standard-v3"

    #   network_interface = {
    #     nat                = false
    #     subnet_ids         = [module.yc-vpc.subnet_id]
    #     security_group_ids = [module.yc-vpc.security_group_id]
    #   }

    #   resources = {
    #     memory = 8
    #     cores  = 2
    #   }

    #   boot_disk = {
    #     type = "network-ssd"
    #     size = 64
    #   }

    #   scheduling_policy = {
    #     preemptible = false
    #   }

    # scale_policy = {
    #   fixed_scale = {
    #     size = 1
    #   }
    # }
    # allocation_policy = { location = { zone = module.yc-vpc.subnet_zone } }
    # }
  }
}

resource "yandex_vpc_network" "bastion-external-network" {
  name = "bastion-external-network"
}

resource "yandex_vpc_subnet" "bastion-external-subnet" {
  network_id = yandex_vpc_network.bastion-external-network.id
  name       = "bastion-external-subnet"

  v4_cidr_blocks = ["192.168.11.0/28"]
}

resource "yandex_vpc_security_group" "bastion-external-sg" {
  name       = "bastion-external-security-group"
  network_id = yandex_vpc_network.bastion-external-network.id

  ingress {
    protocol       = "TCP"
    port           = "22"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_compute_disk" "bastion-disk" {
  name     = "bastion-boot-disk"
  type     = "network-hdd"
  size     = var.vm_resources["vm-bastion"].disk
  image_id = var.images.ubuntu_2204_bastion
  zone     = module.yc-vpc.subnet_zone
}

resource "yandex_compute_instance" "bastion-kuber" {
  name        = "bastion-for-kuber"
  zone        = module.yc-vpc.subnet_zone
  platform_id = "standard-v3"

  resources {
    cores  = var.vm_resources["vm-bastion"].cores
    memory = var.vm_resources["vm-bastion"].memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion-disk.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-external-subnet.id
    index              = 0
    nat                = true
    nat_ip_address     = var.bastion-ips.external
    security_group_ids = [yandex_vpc_security_group.bastion-external-sg.id]
  }

  network_interface {
    subnet_id          = module.yc-vpc.subnet_id
    index              = 1
    ipv4               = true
    ip_address         = var.bastion-ips.internal
    security_group_ids = [module.yc-vpc.security_group_id]
  }

  metadata = {
    user-data = "${file("./cloud-init/bastion.yaml")}"
  }
}