locals {
    folder_id = "b1gnf4rkjrgm97g2ei3k"
    cloud_id = "bpfn9q9caodsckrtpi05"
}

module "interview-task-1" {
    source = "../../modules/csa-interview/interview-task-1"
    vpc_name = "cluster_vpc"

    folder_id = local.folder_id
    cloud_id = local.cloud_id

    environment = "sbx"
    domain = "palkin.nl"
}

