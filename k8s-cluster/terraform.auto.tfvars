service_accounts = {
  kuber = {
    node_acc     = "aje4lqc4ndk2neqaqbuk"
    resource_acc = "aje4lqc4ndk2neqaqbuk"

    # TODO: make service account creating with terraform
    # resource_acc = "aje6gb74tmc2iu27cenn"
  }
}

kuber_ip_range = {
  cluster_range = "10.1.0.0/16"
  service_range = "10.2.0.0/16"
}

kuber_version = "1.28"