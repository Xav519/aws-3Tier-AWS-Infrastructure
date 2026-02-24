variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "db_secret_arn" {
  description = "The ARN of the secret in Secrets Manager"
  type        = string
}