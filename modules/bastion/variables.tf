variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "ami_id" {
  description = "AMI ID pour le Bastion"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet public où déployer le Bastion"
  type        = string
}

variable "security_group_id" {
  description = "Security Group du Bastion"
  type        = string
}

variable "key_name" {
  description = "Nom de la Key Pair pour SSH"
  type        = string
}
