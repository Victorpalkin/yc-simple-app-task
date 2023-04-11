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
  description = "(Required) The ID of the VPC network to be used"
}

variable "static_ip_zone_id" {
  type = string
  description = "(Required) The ID the zone for static IP allocation"
}

variable "cluster_id"{
    
}

variable "cluster_name"{
    
}