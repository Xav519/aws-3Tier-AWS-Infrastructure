
# If you want the External (Public) DNS
output "external_alb_dns_name" {
   value = module.external_alb.alb_dns_name
}

# If you want the Internal (Private) DNS
output "internal_alb_dns_name" {
   value = module.internal_alb.alb_dns_name
}