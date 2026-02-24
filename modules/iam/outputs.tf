output "backend_instance_profile_name" {
  description = "The name of the IAM instance profile for the backend"
  value       = aws_iam_instance_profile.backend_instance_profile.name
}

output "backend_role_arn" {
  description = "The ARN of the backend IAM role"
  value       = aws_iam_role.backend_role.arn
}