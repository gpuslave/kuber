terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.136.0"
    }
  }

  required_version = ">1.10.5"
}

resource "yandex_vpc_network" "bastion-external-network" {
  name = var.external_vpc.network_name
}

resource "yandex_vpc_subnet" "bastion-external-subnet" {
  network_id = yandex_vpc_network.bastion-external-network.id
  name       = var.external_vpc.subnet.name

  v4_cidr_blocks = [var.external_vpc.subnet.cidr]
}

resource "yandex_vpc_security_group" "bastion-external-sg" {
  name       = var.external_vpc.sg.name
  network_id = yandex_vpc_network.bastion-external-network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.external_vpc.sg.ingress_cidr]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_disk" "bastion-disk" {
  name     = var.resources.disk.name
  type     = var.resources.disk.type
  size     = var.resources.disk.size
  image_id = var.resources.disk.image_id
  zone     = var.yandex_provider.zone
}

resource "yandex_compute_instance" "bastion-kuber" {
  name        = var.resources.vm.name
  zone        = var.yandex_provider.zone
  platform_id = "standard-v3"

  resources {
    cores  = var.resources.vm.cores
    memory = var.resources.vm.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion-disk.id
  }

  # ext
  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-external-subnet.id
    index              = 0
    nat                = true
    nat_ip_address     = var.external_vpc.subnet.bastion_ip
    security_group_ids = [yandex_vpc_security_group.bastion-external-sg.id]
  }

  # int
  network_interface {
    subnet_id          = var.internal_vpc.subnet_id
    index              = 1
    ipv4               = true
    ip_address         = var.internal_vpc.bastion_ip
    security_group_ids = [var.internal_vpc.sg_id]
  }

  metadata = {
    user-data = var.cloud_init
    # user-data = "${file("./cloud-init/bastion.yaml")}"
  }
}