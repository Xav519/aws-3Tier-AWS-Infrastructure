variable "project_name" {
  description = "Nom du projet pour préfixer les ressources"
  type        = string
}

variable "alb_name" {
  description = "Nom de l'ALB"
  type        = string
}

variable "alb_type" {
  description = "Type d'ALB : external ou internal"
  type        = string
  default     = "external"
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Liste des subnets où placer l'ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "Liste des Security Groups à associer à l'ALB"
  type        = list(string)
}

variable "listener_ports" {
  description = "Liste des ports à écouter (HTTP/HTTPS)"
  type        = list(number)
  default     = [80]
}

variable "target_group_name" {
  description = "Nom du Target Group que l'ALB va cibler"
  type        = string
}
