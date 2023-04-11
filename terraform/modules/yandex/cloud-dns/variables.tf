variable "environment" {
  type = string
  description = "(Required) Deployment environment (Sandbox, dev, qa, prod)"
}

variable "folder_id" {
  type = string
  description = "(Required) The id of the folder for the resources to be deployed to"
}

variable "domain" {
  type = string
  description = "(Required)The domain name for the public zone to be created"
}

variable "records" {
    type = list(object({
        name = string
        type = string
        data = list(string)
        ttl = string
    }))
    description = "(Optional)The domain name for the public zone to be created"
    default = [ ]
}