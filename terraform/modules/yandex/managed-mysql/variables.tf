variable "environment" {
  type = string
  description = "(Required) Deployment environment (Sandbox, dev, qa, prod)"
}

variable "folder_id" {
  type = string
  description = "(Required) The id of the folder for the resources to be deployed to"
}

variable "vpc_network_id" {
  type = string
  description = "(Required) The ID of the VPC for the MySQL instance"
}

variable "hosts_subnets" {
    type = list(object({
        zone = string
        id = string
    }))
    description = "(Required) A list of subnets and zones to deploy hosts to"
}

variable "cluster_name" {
    type = string
    description = "(Optional) The name for the managed MySQL cluster"
    default = "mysql"
}

variable "mysql_version" {
    type = string
    description = "(Optional) Version of MySQL to be deployed"
    default = "8.0"
}

variable "app_name" {
    type = string
    description = "(Required) Application name for the database instance"
}

variable "resource_preset_id" {
  type = string
  description = "(Optional)"
  default = "s2.micro"
}