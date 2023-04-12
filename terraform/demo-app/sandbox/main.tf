locals {
    folder_id = "b1gnf4rkjrgm97g2ei3k"
    cloud_id = "b1gdruhd9eunnnv8uaam"
    certificate_id = "fpqheas4dpk0uc0jkdu8"
    dns_zone_id = "dnsfiblsk0qqn22sd20d"
    container_registry_id = "crp5s7djubffko1pkrub"
    environment = "sbx"
    vpc_name = "demo_vpc"
    hostname = "palkin.nl"
}

module "interview-task-1" {
    source = "../../modules/csa-interview/interview-task-1"

    vpc_name = local.vpc_name

    folder_id = local.folder_id
    cloud_id = local.cloud_id

    environment = local.environment
    dns_zone_id = local.dns_zone_id
    certificate_id = local.certificate_id
    host = local.hostname

    container_registry_id = local.container_registry_id
}

