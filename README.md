# Kubernetes Sandbox - Terraform Configuration

This project provides a Terraform configuration for deploying a Kubernetes cluster and related infrastructure on Yandex Cloud. It's designed to be a sandbox environment for learning and experimenting with Kubernetes.

## Table of Contents

- [Kubernetes Sandbox - Terraform Configuration](#kubernetes-sandbox---terraform-configuration)
  - [Table of Contents](#table-of-contents)
  - [1. Project Overview](#1-project-overview)
  - [2. Prerequisites](#2-prerequisites)
  - [3. Getting Started](#3-getting-started)
  - [4. Terraform Modules](#4-terraform-modules)
  - [5. Variables](#5-variables)
  - [6. Outputs](#6-outputs)
  - [7. Usage](#7-usage)
    - [Connecting to the Kubernetes Cluster](#connecting-to-the-kubernetes-cluster)

## 1. Project Overview

This Terraform project automates the creation of the following resources on Yandex Cloud:

*   **Virtual Private Cloud (VPC):** A network to isolate your Kubernetes cluster.
*   **Subnets:** Subnets within the VPC for the Kubernetes nodes and other resources.
*   **Security Groups:** Firewall rules to control network traffic to and from the cluster.
*   **Kubernetes Cluster:** A managed Kubernetes cluster using Yandex Kubernetes Engine (YKE).
*   **Node Groups:** Groups of virtual machines that form the worker nodes of the Kubernetes cluster.
*   **Bastion Host (Optional):** A secure gateway for accessing the Kubernetes cluster and other resources within the VPC.
*   **Routing Table (Optional):** Configures routing for the cluster.

The project is structured into reusable Terraform modules to promote modularity and maintainability.

## 2. Prerequisites

Before you can use this Terraform configuration, you'll need the following:

*   **Yandex Cloud Account:** You'll need an active Yandex Cloud account with sufficient permissions to create the resources described above.
*   **Terraform:** Install Terraform (version `~>1.10.5` or later) on your local machine.  See [Terraform's official documentation](https://www.terraform.io/downloads.html) for installation instructions.
*   **Yandex Cloud CLI (Optional):** The Yandex Cloud CLI (`yc`) is helpful for authenticating and managing your Yandex Cloud resources.  See [Yandex Cloud documentation](https://cloud.yandex.com/en/docs/cli/quickstart) for installation instructions.
*   **Authentication:** Configure Terraform to authenticate with your Yandex Cloud account. This can be done using:
    *   **Service Account and Key:** Recommended for automation.  You'll need to create a service account with the appropriate roles and download a key file.
    *   **Static Credentials:** Not recommended for production use.
*   **S3 Bucket for Terraform State:** Create an S3 bucket to store your Terraform state file. This is crucial for collaboration and managing your infrastructure over time.

## 3. Getting Started

Follow these steps to deploy the Kubernetes cluster:

1.  **Clone the Repository:**

    ```bash
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Configure Terraform Backend:**

    Edit the `terraform { backend "s3" { ... } }` block in [main.tf](http://_vscodecontentref_/0) to configure your S3 bucket for storing the Terraform state.  Replace the placeholders with your actual bucket name, key, and region:

    ```terraform
    terraform {
      backend "s3" {
        bucket = "your-terraform-state-bucket"
        key    = "kuber/terraform.tfstate"
        region = "ru-central1" # Or your Yandex Cloud region
      }
    }
    ```

3.  **Set Environment Variables:**

    Set the required environment variables for your Yandex Cloud provider.  This typically includes your Yandex Cloud token, zone, folder ID, and cloud ID.  Alternatively, you can define these variables directly in a `terraform.tfvars` file (not recommended for sensitive values).

    ```bash
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
    export YC_ZONE=$(yc config get compute-default-zone)

    export ACCESS_KEY="your_access_key"
    export SECRET_KEY="your_secret_key"

    export TF_VAR_yandex_provider="{\"token\":\"$YC_TOKEN\",\"zone\":\"$YC_ZONE\",\"folder_id\":\"$YC_FOLDER_ID\",\"cloud_id\":\"$YC_CLOUD_ID\"}"
    ```

4.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

    This command initializes the Terraform working directory, downloads the required providers, and configures the backend.

5.  **Plan Terraform:**

    ```bash
    terraform plan
    ```

    This command creates an execution plan, showing you the changes that Terraform will make to your infrastructure.  Review the plan carefully to ensure that it matches your expectations.

6.  **Apply Terraform:**

    ```bash
    terraform apply
    ```

    This command applies the changes described in the execution plan, creating the resources in your Yandex Cloud account.  You'll be prompted to confirm the changes before Terraform proceeds.

7.  **Access the Kubernetes Cluster:**

    Once the Terraform apply is complete, you can access your Kubernetes cluster using `kubectl`.  You'll need to configure `kubectl` to authenticate with your Yandex Kubernetes Engine (YKE) cluster.  Refer to the Yandex Cloud documentation for instructions on how to do this.

## 4. Terraform Modules

This project is organized into the following Terraform modules:

*   **[vpc]():** Creates the VPC, subnets, and security groups.
*   **[k8s]():** Deploys the Kubernetes cluster and node groups.
*   **[bastion]():** (Optional) Creates a bastion host for secure access to the cluster.
*   **[bastion-routing]():** (Optional) Creates a routing table for the bastion host.

## 5. Variables

The following variables can be configured to customize your deployment. These variables are defined in the `variables.tf` files within each module and in the root [k8s-cluster]() directory.

*   **`yandex_provider`:** (Object) Yandex Cloud provider configuration (token, zone, folder ID, cloud ID).
*   **`cidr_blocks`:** (Object) CIDR blocks for the VPC and subnets.
*   **`kuber_service_accounts`:** (Object) Service accounts for the Kubernetes cluster.
*   **`kuber_ip_range`:** (String) IP range for the Kubernetes cluster.
*   **`kuber_version`:** (String) Kubernetes version.
*   **`cluster_name`:** (String) Name of the Kubernetes cluster.
*   **`node_groups`:** (Object) Configuration for the node groups.
*   **`images`:** (Map) Map of image IDs for the bastion host and other resources.
*   **`bastion-ips`:** (Object) External and internal IP addresses for the bastion host.
*   **`vm_resources`:** (Map) VM resources configuration (cores, memory, disk) for the bastion host and other resources.
*   **`create_route_table`:** (Boolean) Whether to create a route table.

See the `variables.tf` files for detailed descriptions and default values.

## 6. Outputs

The project outputs the following values, which can be used to access and manage your infrastructure:

*   **`network_id`:** The ID of the VPC network.
*   **`subnet_id`:** The ID of the subnet.
*   **`security_group_id`:** The ID of the security group.
*   **`bastion_instance_id`:** The ID of the bastion host instance (if created).
*   **`bastion_external_ip`:** The external IP address of the bastion host (if created).
*   **`bastion_internal_ip`:** The internal IP address of the bastion host (if created).
*   **`route_table_id`:** The ID of the route table (if created).

These outputs can be accessed using the `terraform output` command.

## 7. Usage

### Connecting to the Kubernetes Cluster

After the cluster is deployed, you can connect to it using `kubectl`. You'll need to configure `kubectl` to authenticate with your Yandex Kubernetes Engine (YKE) cluster. Refer to the Yandex Cloud documentation for instructions on how to do this.