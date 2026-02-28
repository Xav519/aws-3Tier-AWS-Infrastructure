
module "vpc" {
  source = "../modules/vpc" # Source of the VPC module, which is located in the parent directory under modules/vpc

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnets      = var.public_subnets
  presentation_subnets = var.presentation_subnets
  logic_subnets       = var.logic_subnets
  database_subnets    = var.database_subnets
}

module "security_groups" {
  source = "../modules/security-groups"

  project_name = var.project_name
  vpc_id      = module.vpc.vpc_id
}

# External ALB
module "external_alb" {
  source           = "../modules/alb"
  project_name     = var.project_name
  alb_name         = "external-alb"
  alb_type         = "external"
  vpc_id           = module.vpc.vpc_id
  # no need to put ALB in their own subnets, we can share it with the public subnets for simplicity
  subnet_ids       = module.vpc.public_subnets
  security_groups  = [module.security_groups.external_alb_sg_id]
  target_port       = 3000
  target_group_name = "presentation-tg"
}

# Internal ALB
module "internal_alb" {
  source           = "../modules/alb"
  project_name     = var.project_name
  alb_name         = "internal-alb"
  alb_type         = "internal"
  vpc_id           = module.vpc.vpc_id
  # no need to put ALB in their own subnets, we can share it with the presentation subnets for simplicity
  subnet_ids       = module.vpc.presentation_subnets
  security_groups  = [module.security_groups.internal_alb_sg_id]
  # LISTEN on 80, but SEND to 8080
  target_port       = 8080 
  
  # Your script tests /goals, so let the ALB check that too!
  health_check_path = "/goals"


  target_group_name = "logic-tg"
}

# Bastion Host
module "bastion" {
  source            = "../modules/bastion"
  project_name      = var.project_name
  # Find a valid ami id for your bastion host: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
  ami_id            = "ami-080e1f13689e07408"
  instance_type     = "t2.micro"
  subnet_id         = module.vpc.public_subnets[0]
  security_group_id = module.security_groups.bastion_sg_id
  key_name          = var.bastion_key_name # add your key pair name here
}

# RDS Instance
module "rds" {
  source = "../modules/rds"

  project_name = "three-tier"

  db_subnet_ids = module.vpc.database_subnets

  vpc_security_group_ids = [module.security_groups.rds_main_sg_id]

  engine            = "postgres"
  engine_version    = "15.10"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

# Temporary: using hardcoded credentials for simplicity, to be replaced with Secrets Manager !!!
  db_name  = "appdb"
  username = "xav519_db"
# password = var.db_password # Best to use the random_password result here
  password = "StrongPassword123!"
}


# Secrets Manager Module
module "secrets" {
  source = "../modules/secrets"

  environment = var.environment
  project     = var.project_name

# TODO: replace by results from random_password once implemented in RDS module
  db_username = "xav519_db"
  db_password = "StrongPassword123!"

  # RDS endpoint injected here
  db_host = module.rds.db_address

  db_port = 5432
  db_name = "appdb"

  recovery_window_in_days = 0

  tags = {
    Project     = var.project_name
  }

  depends_on = [module.rds]
}


# IAM Module (for EC2 instance profile and permissions to access Secrets Manager)
module "iam" {
  source        = "../modules/iam"
  project_name  = var.project_name
  db_secret_arn = module.secrets.db_secret_arn
}

# Generate random password for database. Implementation of this will be done in the secrets manager module, but we need to generate it here to inject it into the RDS module for now. This is temporary and will be refactored later.
resource "random_password" "db_password" {
  length  = 16
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Frontend ASG
module "frontend_asg" {
  source            = "../modules/frontend-asg"
  region = var.region
  environment = var.environment
  project_name      = var.project_name
  # Find a valid ami id for your region: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
  ami_id            = "ami-080e1f13689e07408"
  instance_type     = "t2.micro"

  subnet_ids        = module.vpc.presentation_subnets
  security_group_id = module.security_groups.presentation_ec2_sg_id
  target_group_arn  = module.external_alb.target_group_arn

  key_name          = var.bastion_key_name

  # This pulls the DNS name from your internal load balancer module
  backend_internal_url = "http://${module.internal_alb.alb_dns_name}"
  
  # Provide the name of your frontend image
  docker_image         = "xav519/goal-tracker-frontend:v4" # replace with your Docker Hub username and image name
  # ---------------------------

  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

# Backend ASG
module "backend_asg" {
  source            = "../modules/backend-asg"
  project_name      = var.project_name
  region = var.region
  environment = var.environment

  # Find a valid ami id for your region: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
  ami_id            = "ami-080e1f13689e07408"
  instance_type     = "t2.micro"

  subnet_ids        = module.vpc.logic_subnets
  security_group_id = module.security_groups.logic_ec2_sg_id
  target_group_arn  = module.internal_alb.target_group_arn

  key_name          = var.bastion_key_name

# Pass the output from the new IAM module
  iam_instance_profile = module.iam.backend_instance_profile_name
 
  # Required by your backend user_data script
  docker_image  = "xav519/goal-tracker-backend:v1" # Replace with your Docker Hub username and image name
  db_secret_arn = module.secrets.db_secret_arn

  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

