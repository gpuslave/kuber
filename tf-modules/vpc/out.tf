output "network_id" {
  value = yandex_vpc_network.kuber-vpc.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.kuber-subnet.id
}

output "subnet_zone" {
  value = yandex_vpc_subnet.kuber-subnet.zone
}

output "security_group_id" {
  value = yandex_vpc_security_group.kuber-sg.id
}