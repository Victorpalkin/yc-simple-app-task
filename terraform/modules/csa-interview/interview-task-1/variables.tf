variable "environment" {
  type = string
  description = "(Required) Deployment environment (Sandbox, dev, qa, prod)"
}

variable "folder_id" {
  type = string
  description = "(Optional) The id of the folder for the resources to be deployed to. If not provided - new folder will be created"
  default = ""
}

variable "cloud_id" {
  type = string
  description = "(Required) The id of the cloud for the resources to be deployed to"
}

variable "vpc_name" {
  type = string
  description = "(Optional) The name of the VPC network to be created"
  default = ""
}

variable "cidr_ranges" {
    type = list(string)
    description = "(Optional) The CIDR ranges for zonal subnets to be created in the new VPC"
    default = []
}

variable "cluster_name" {
    type = string
    description = "(Optional) The name of the cluster to be created"
    default = "my-cluster"
}

variable "k8s_version" {
  type = string
  description = "(Optional) The version for the cluster to be created"
  default = "1.23"
}

variable "host" {
  type = string
  description = "(Required) The host for the application"
}

variable "certificate_id" {
  type = string
  description = "(Required) The ID of the certificate for the https tls access. Create it and validate it before the deployment"
}

variable "dns_zone_id" {
  type = string
  description = "(Required) The existing DNS zone to create a record at"
}

variable "container_registry_id" {
  type = string
  description = "(Required) The container registry id where the application containers are located"
}
