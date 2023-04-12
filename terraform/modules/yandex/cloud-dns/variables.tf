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
  description = "(Optional)The domain name for the public zone to be created. Use only if you want to create a zone"
  default = ""
}

variable "zone_id" {
  type = string
  description = "(Optional) The existing zone to create a record in."
  default = ""
}

variable "records" {
    type = list(object({
        name = string
        type = string
        data = list(string)
        ttl = string
    }))
    description = "(Optional)The domain name for the public zone to be created. Only if you want to create the records"
    default = [ ]
}