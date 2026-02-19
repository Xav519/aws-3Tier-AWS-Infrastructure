variable "project_name" {
  description = "Project name"
  type        = string
}

variable "db_subnet_ids" {
  description = "Private subnets for the database"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security Groups for RDS"
  type        = list(string)
}

variable "engine" {
  description = "Database engine (mysql or postgres)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage size in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "username" {
  description = "Database admin username"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}
