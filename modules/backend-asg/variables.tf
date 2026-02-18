variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "ami_id" {
  description = "AMI ID pour les instances backend"
  type        = string
}

variable "instance_type" {
  description = "Type EC2"
  type        = string
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "Subnets privés du layer 2 (logic)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group du backend (logic)"
  type        = string
}

variable "target_group_arn" {
  description = "Target Group ARN de l'Internal ALB"
  type        = string
}

variable "key_name" {
  description = "Key pair pour SSH via bastion"
  type        = string
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}
