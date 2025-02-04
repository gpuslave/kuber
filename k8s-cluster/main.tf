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

  vpc = {
    network_id        = module.yc-vpc.network_id
    subnet_id         = module.yc-vpc.subnet_id
    subnet_zone       = module.yc-vpc.subnet_zone
    security_group_id = module.yc-vpc.security_group_id
  }

  kuber_instance_template = {
    platform_id = "standard-v3"

    network_interface = {
      nat                = true
      subnet_ids         = [module.yc-vpc.subnet_id]
      security_group_ids = [module.yc-vpc.security_group_id]
    }

    resources = {
      memory = 4
      cores  = 2
    }

    boot_disk = {
      type = "network-ssd"
      size = 96
    }

    scheduling_policy = {
      preemptible = false
    }

    container_runtime = {
      type = "containerd"
    }
  }
}