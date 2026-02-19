variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the Bastion host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Public subnet where the Bastion host will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security Group for the Bastion host"
  type        = string
}

variable "key_name" {
  description = "Key pair name used for SSH access"
  type        = string
}
