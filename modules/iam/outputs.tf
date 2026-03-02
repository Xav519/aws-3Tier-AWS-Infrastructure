output "ec2_instance_profile_name" {
  description = "The name of the IAM instance profile for the EC2 instance"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_role_arn" {
  description = "The ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}