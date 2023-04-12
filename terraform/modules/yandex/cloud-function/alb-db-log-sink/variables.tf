variable "environment" {
  type = string
  description = "(Required) Deployment environment (Sandbox, dev, qa, prod)"
}

variable "folder_id" {
  type = string
  description = "(Required) The id of the folder for the resources to be deployed to"
}

variable "function_name"{
    type = string
    description = "(Required) The name of the function to be created"
}

variable "function_description"{
    type = string
    description = "(Required) The description of the function to be created"
}

variable "db_username" {
    type = string
    description = "(Required) The username for the MySQL database"
}

variable "db_password_secret_id" {
    type = string
    description = "(Required) The lockbox secret id where password is store"
}

variable "db_password_secret_version_id" {
    type = string
    description = "(Required) The lockbox secret version id where password is store"
}

variable "db_password_secret_kay" {
    type = string
    description = "(Required) The lockbox secret key for the password value"
}

variable "db_hostname"{
    type = string
    description = "(Required) The hostname of the MySQL database"
}

variable "db_name" {
    type = string
    description = "(Required) The name of the database to sink logs to"
}

variable "db_port" {
    type = string
    description = "(Required) The port of the MySQL database"
}

variable "load_balancer_ids" {
    type = list(string)
    description = "(Required) The IDs of the load balancer which logs you want to sink to the MySQL database" 
}