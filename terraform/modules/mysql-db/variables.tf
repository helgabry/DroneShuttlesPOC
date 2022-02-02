variable "resource_group_name" {
  type        = string
  description = "The resource group that db should be deployed into"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = "dev"
}

variable "primary_location" {
  type        = string
  description = "The Azure active region where all resources should be created"
  default     = ""
}

variable "secondary_location" {
  type        = string
  description = "The Azure active region where all resources should be created"
  default     = ""
}

variable "mysql_database_username" {
  type        = string
  description = "The MySQL administrator login"
}

variable "mysql_database_password" {
   type        = string
  description = "The MySQL administrator login password"
}

variable "database_name" {
  type        = string
  description = "The MySQL database name"
  default     = "ghost"
}
