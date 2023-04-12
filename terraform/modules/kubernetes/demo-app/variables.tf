variable "namespace" {
  type = string
  description = "(optional) Kubernetes namespace to be created"
  default = "demo-app"
}

variable "subnet_ids" {
  type = string
  description = "(Required) Comma-separated ids of subnets for the load balancer"
}

variable "security_group_ids" {
  type = string
  description = "(Required) Comma-separated ids of security groups for the load balancer"
}

variable "external_ip_adress" {
  type = string
  description = "(Required) The external IP adress created for the load balancer"
}

variable "host" {
  type = string
  description = "(Required) The name of the host for the app"
}

variable "certificate_id" {
  type = string
  description = "(Required) The certificate id in certificate manager for TLS"
}

variable "container_registry_id" {
  type = string
  description = "(Required) The container registry id where the applications are located"
}