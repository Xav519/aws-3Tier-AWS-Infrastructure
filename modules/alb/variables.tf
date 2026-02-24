variable "project_name" {
  description = "Project name used to prefix AWS resources"
  type        = string
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "alb_type" {
  description = "Type of ALB: external (internet-facing) or internal"
  type        = string
  default     = "external"
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ALB will be placed"
  type        = list(string)
}

variable "security_groups" {
  description = "List of Security Group IDs to associate with the ALB"
  type        = list(string)
}

variable "listener_ports" {
  description = "List of ports the ALB listeners will use (e.g., HTTP/HTTPS)"
  type        = list(number)
  default     = [80] # Default to standard HTTP
}

variable "target_group_name" {
  description = "Name of the Target Group that the ALB will forward traffic to"
  type        = string
}

variable "target_port" {
  description = "The port the service is actually listening on (Ex: 8080 for Docker)"
  type        = number
  default     = 80 # Default to standard HTTP
}

variable "health_check_path" {
  description = "The path for the health check"
  type        = string
  default     = "/"
}
