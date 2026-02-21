variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for backend instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "Private subnets for the logic layer (Layer 2)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group for the backend (logic tier)"
  type        = string
}

variable "target_group_arn" {
  description = "Target Group ARN of the Internal ALB"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name (used for debugging via bastion host)"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

// Variables for Docker image and credentials

variable "docker_image" {
  description = "Full Docker image name (e.g., username/image:tag)"
  type        = string
}

variable "dockerhub_username" {
  description = "Docker Hub username (optional for public images)"
  type        = string
  default     = ""
}

variable "dockerhub_password" {
  description = "Docker Hub password or access token (optional for public images)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_secret_arn" {
  description = "ARN of Secrets Manager secret containing database credentials"
  type        = string
}
