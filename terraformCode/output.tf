
# Quick Start Commands
output "helpful_commands" {
  description = "Helpful commands for working with this infrastructure"
  value       = <<-EOT
    
    ═══════════════════════════════════════════════════════════════════
                    Goal Tracker Infrastructure
    ═══════════════════════════════════════════════════════════════════
    
    🌐 Application URL:
       http://${module.external_alb.alb_dns_name}
    
    🔐 SSH to Bastion:
       ssh -i your-key.pem ec2-user@${module.bastion.public_ip}
    
    📦 Push Docker Images to Docker Hub:
       # Login to Docker Hub
       docker login
       
       # Build and push frontend
       cd ../dockerDeployment/frontend
       docker build -t xav519/goal-tracker-frontend:v1 .
       docker push xav519/goal-tracker-frontend:v1
       
       # Build and push backend
       cd ../dockerDeployment/backend
       docker build -t xav519/goal-tracker-backend:v1 .
       docker push xav519/goal-tracker-backend:v1
    
    🗄️ Get Database Credentials:
       aws secretsmanager get-secret-value --secret-id ${module.secrets.db_secret_name} --region ${var.region} --query SecretString --output text | jq .
    
    📊 View Logs:
       Connect to Bastion host and to the appropriate ec2 instance and then use the following commands to view logs:
       - Frontend logs: sudo docker logs goal-tracker-frontend
       - Backend logs: sudo docker logs goal-tracker-backend
  EOT
}