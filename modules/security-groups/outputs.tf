output "bastion_sg_id" {
  description = "Security Group ID of the Bastion Host"
  value       = aws_security_group.bastion.id
}

output "external_alb_sg_id" {
  description = "Security Group ID of the External ALB"
  value       = aws_security_group.external_alb.id
}

output "presentation_ec2_sg_id" {
  description = "Security Group ID of Tier 1 (Presentation) EC2 instances"
  value       = aws_security_group.presentation_ec2.id
}

output "internal_alb_sg_id" {
  description = "Security Group ID of the Internal ALB"
  value       = aws_security_group.internal_alb.id
}

output "logic_ec2_sg_id" {
  description = "Security Group ID of Tier 2 (Logic) EC2 instances"
  value       = aws_security_group.logic_ec2.id
}

output "rds_main_sg_id" {
  description = "Security Group ID of the primary RDS instance"
  value       = aws_security_group.rds_main.id
}

output "rds_replica_sg_id" {
  description = "Security Group ID of the RDS replica instance"
  value       = aws_security_group.rds_replica.id
}
