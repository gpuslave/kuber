terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.135.0"
    }
  }

  required_version = "~>1.10.5"
}

resource "yandex_vpc_network" "kuber-vpc" {
  name = "kuber-vpc-network"
}

resource "yandex_vpc_security_group" "kuber-sg" {
  name        = "kuber-cluster-sg"
  description = "kuber"
  network_id  = yandex_vpc_network.kuber-vpc.id

  ingress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [var.cidr_blocks.cluster_ingress]
    # v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [var.cidr_blocks.cluster_egress]
    # v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_subnet" "kuber-subnet" {
  name           = "kuber-cluster-subnet"
  zone           = var.yandex_provider.zone
  network_id     = yandex_vpc_network.kuber-vpc.id
  v4_cidr_blocks = [var.cidr_blocks.subnet]
  # v4_cidr_blocks = [ "192.168.1.0/24" ]
}