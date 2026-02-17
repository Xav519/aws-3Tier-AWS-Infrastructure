output "bastion_sg_id" {
  description = "ID du Security Group du Bastion Host"
  value       = aws_security_group.bastion.id
}

output "external_alb_sg_id" {
  description = "ID du Security Group de l'External ALB"
  value       = aws_security_group.external_alb.id
}

output "presentation_ec2_sg_id" {
  description = "ID du Security Group des EC2 Tier 1 (Presentation)"
  value       = aws_security_group.presentation_ec2.id
}

output "internal_alb_sg_id" {
  description = "ID du Security Group de l'Internal ALB"
  value       = aws_security_group.internal_alb.id
}

output "logic_ec2_sg_id" {
  description = "ID du Security Group des EC2 Tier 2 (Logic)"
  value       = aws_security_group.logic_ec2.id
}

output "rds_main_sg_id" {
  description = "ID du Security Group du RDS principal"
  value       = aws_security_group.rds_main.id
}

output "rds_replica_sg_id" {
  description = "ID du Security Group du RDS Replica"
  value       = aws_security_group.rds_replica.id
}
