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

resource "yandex_iam_service_account" "account" {
  folder_id = var.folder_id

  name        = "${var.cluster_name}-sa"
  description = "${var.cluster_name} regional service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "function_invoker" {
  folder_id = var.folder_id
  role      = "serverless.functions.invoker"
  members = [
    "serviceAccount:${yandex_iam_service_account.account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "lockbox_payload_viewer" {
  folder_id = var.folder_id
  role      = "lockbox.payloadViewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.account.id}"
  ]
}

data "archive_file" "zip_function" {
  output_path = "${path.module}/function.zip"
  type = "zip"
  source_dir = "${path.module}/assets"
  output_file_mode = "0666"
}

resource "yandex_function" "sink_function" {
  folder_id = var.folder_id

  name               = var.function_name
  description        = var.function_description
  user_hash          = data.archive_file.zip_function.output_sha
  runtime            = "python37"
  entrypoint         = "main"
  memory             = "128"
  execution_timeout  = "10"
  service_account_id = yandex_iam_service_account.account.id
  labels = module.labels.labels

  secrets {
    id = var.db_password_secret_id
    version_id = "${yandex_lockbox_secret_version.secret_version.id}"
    key = var.db_password_secret_key
    environment_variable = "DB_PASSWORD"
  }
  environment = {
    "DB_USER" = var.db_username,
    "DB_PORT" = var.db_port,
    "DB_HOSTNAME" = var.db_hostname,
    "DB_NAME" = var.db_name
  }


  content {
    zip_filename = data.archive_file.output_path
  }
}

resource "yandex_function_trigger" "alb_trigger" {
  name        = "some_name"
  description = "any description"
  timer {
    cron_expression = "* * * * ? *"
  }
  function {
    id = "tf-test"
  }
}