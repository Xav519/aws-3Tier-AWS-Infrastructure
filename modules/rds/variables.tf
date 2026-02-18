variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "db_subnet_ids" {
  description = "Subnets privés pour la base de données"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security Groups pour RDS"
  type        = list(string)
}

variable "engine" {
  description = "Moteur DB (mysql ou postgres)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Version du moteur"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "Type d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Stockage initial en GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nom de la base"
  type        = string
}

variable "username" {
  description = "Username admin"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Mot de passe admin"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Activer Multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Nombre de jours de backup"
  type        = number
  default     = 7
}
