terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
  required_version = ">= 1.4.4"
}

module "labels" {
    source = "../labels"

    environment = var.environment
}

data "yandex_compute_image" "ubuntu" {
    folder_id = "standard-images"
    family = "ubuntu-2204-lts"

}

resource "yandex_compute_instance_group" "group1" {
  name                = var.group_name
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.account.id
  deletion_protection = true
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "${data.yandex_compute_image.ubuntu.id}"
        size     = 4
      }
    }
    network_interface {
      network_id = var.vpc_network_id
      subnet_ids = var.subnets.*.id
      }
    labels = module.labels.labels
    
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  variables = {
    test_key1 = "test_value1"
    test_key2 = "test_value2"
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }
}

resource "yandex_iam_service_account" "account" {
  name        = "${var.group_name}-sa"
  description = "${var.group_name} regional service account"
}


resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {
  # The service account is assigned the vpc.publicAdmin role.
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.account.id}"
  ]
}