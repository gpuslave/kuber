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

module "yc-ypc" {
  source = "../tf-modules/vpc"

  yandex_provider = var.yandex_provider

  cidr_blocks = {
    cluster_egress  = "0.0.0.0/0"
    cluster_ingress = "0.0.0.0/0"
    subnet          = "192.168.10.0/24"
  }
}