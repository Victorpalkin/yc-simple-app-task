variable "environment" {
  type = string
  description = "(Required) Deployment environment (Sandbox, dev, qa, prod)"
}

variable "folder_id" {
  type = string
  description = "(Required) The id of the folder for the resources to be deployed to"
}

variable "vpc_name" {
  type = string
  description = "(Optional) The name of the VPC network to be created. Otherwise default VPC network will be used"
  default = ""
}

variable "subnets" {
    type = list(object({
        zone = string
        v4_cidr_blocks = list(string)
    }))
    description = "(Optional) The list of string maps with the following keys - zone, CIDR range. No subnets created by default"
    default = []
}