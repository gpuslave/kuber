terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.136.0"
    }
  }

  required_version = ">1.10.5"
}

resource "yandex_vpc_gateway" "kuber-nat-gateway" {
  count = var.gateway_routing ? 1 : 0

  name = "kuber-egress-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "kuber-nat-route-table" {
  name       = var.rt_name
  network_id = var.network_id

  dynamic "static_route" {
    for_each = var.static_routes
    content {
      destination_prefix = static_route.value.destination_prefix
      next_hop_address   = var.gateway_routing ? null : static_route.value.next_hop_address
      gateway_id         = var.gateway_routing ? yandex_vpc_gateway.kuber-nat-gateway[0] : null
    }
  }
}