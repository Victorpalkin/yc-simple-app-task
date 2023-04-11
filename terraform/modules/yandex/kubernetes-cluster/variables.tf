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
  description = "(Optional) The ID of the VPC network to be used"
  default = ""
}

variable "master_subnets" {
  type = list(object({
    zone = string
    v4_cidr_blocks = list(string)
    id = string
  }))
}

variable "node_subnets" {
  type = list(object({
    zone = string
    v4_cidr_blocks = list(string)
    id = string
  }))
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

