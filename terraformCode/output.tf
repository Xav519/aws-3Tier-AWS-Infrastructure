
# Output the ALB DNS name so we can use it to access our application
output "alb_dns_name" {
  value = module.alb.aws_lb.this.dns_name
}