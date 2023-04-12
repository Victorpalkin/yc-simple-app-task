module "labels" {
    source = "../labels"

    environment = var.environment
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
    random = {
      version = ">=3.4.3"
    }
  }
  required_version = ">= 1.4.4"
}

resource "yandex_mdb_mysql_cluster" "main" {
  folder_id = var.folder_id

  name        = var.cluster_name
  environment = "PRODUCTION"
  network_id  = var.vpc_network_id
  version     = var.mysql_version

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = 100
    default_authentication_plugin = "SHA256_PASSWORD"
    innodb_print_all_deadlocks    = true
  }


  dynamic "host" {
    for_each = var.hosts_subnets
    content {
          zone = host.value["zone"]
          subnet_id = host.value["id"]
    }
  }

  labels = module.labels.labels

  lifecycle {
    ignore_changes = [
      version
    ]
  }
}

resource "yandex_mdb_mysql_database" "service" {
  cluster_id = yandex_mdb_mysql_cluster.main.id
  name       = "${var.cluster_name}-${var.environment}-${var.app_name}-db"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  folder_id = var.folder_id
  name              = "${var.environment}-${var.app_name}-secret-kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 year.

  labels = module.labels.labels
}

resource "yandex_lockbox_secret" "admin_password" {
  folder_id = var.folder_id
  name = "${var.environment}-${var.app_name}-admin-password"
  kms_key_id = yandex_kms_symmetric_key.kms-key.id

  labels = module.labels.labels

}

resource "random_password" "password" {
  length            = 40
  special           = true
  min_special       = 3
  override_special  = "~!@#$%()"
  min_lower = 3
  min_upper = 3
  min_numeric = 3
}

resource "yandex_lockbox_secret_version" "admin_password_version" {
  secret_id = yandex_lockbox_secret.admin_password.id
  entries {
    key        = "password"
    text_value = random_password.password.result
  }
}

resource "yandex_mdb_mysql_user" "admin" {
    cluster_id = yandex_mdb_mysql_cluster.main.id
    name       = "${var.environment}-${var.app_name}-admin"
    password   = random_password.password.result

    permission {
      database_name = yandex_mdb_mysql_database.service.name
      roles         = ["ALL"]
    }

    connection_limits {
      max_questions_per_hour   = 10
      max_updates_per_hour     = 20
      max_connections_per_hour = 30
      max_user_connections     = 40
    }

    global_permissions = ["PROCESS"]

    authentication_plugin = "SHA256_PASSWORD"
}