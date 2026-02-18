
module "vpc" {
  source = "../modules/vpc" 

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
  source           = "./modules/alb"
  project_name     = var.project_name
  alb_name         = "external-alb"
  alb_type         = "external"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnets
  security_groups  = [module.sg.external_alb_sg_id]
  listener_ports   = [80, 443]
  target_group_name = "presentation-tg"
}

# Internal ALB
module "internal_alb" {
  source           = "./modules/alb"
  project_name     = var.project_name
  alb_name         = "internal-alb"
  alb_type         = "internal"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.presentation_subnets
  security_groups  = [module.sg.internal_alb_sg_id]
  listener_ports   = [80]
  target_group_name = "logic-tg"
}

# Bastion Host
module "bastion" {
  source            = "./modules/bastion"
  project_name      = var.project_name
  ami_id            = "ami-xxxxxxxx" # AMI Amazon Linux par exemple à rajouter
  instance_type     = "t2.micro"
  subnet_id         = module.vpc.public_subnets[0]
  security_group_id = module.sg.bastion_sg_id
  key_name          = "my-keypair"
}

# Frontend ASG
module "frontend_asg" {
  source            = "./modules/frontend-asg"
  project_name      = var.project_name

  ami_id            = "ami-xxxxxxxx"
  instance_type     = "t2.micro"

  subnet_ids        = module.vpc.presentation_subnets
  security_group_id = module.sg.presentation_ec2_sg_id
  target_group_arn  = module.external_alb.target_group_arn

  key_name          = "my-keypair"

  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

# Backend ASG
module "backend_asg" {
  source            = "./modules/backend-asg"
  project_name      = var.project_name

  ami_id            = "ami-xxxxxxxx"
  instance_type     = "t2.micro"

  subnet_ids        = module.vpc.logic_subnets
  security_group_id = module.sg.logic_ec2_sg_id
  target_group_arn  = module.internal_alb.target_group_arn

  key_name          = "my-keypair"

  desired_capacity  = 2
  min_size          = 2
  max_size          = 4
}

# RDS Instance
module "rds" {
  source = "./modules/rds"

  project_name = "three-tier"

  db_subnet_ids = module.vpc.database_subnets

  vpc_security_group_ids = [
    module.sg.rds_main_sg_id
  ]

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = "admin"
  password = "StrongPassword123!"
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Secrets Manager Module
module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
  project     = var.project
  db_username = var.db_username
  db_password = random_password.db_password.result
  db_host     = module.rds.db_address
  db_port     = module.rds.db_port
  db_name     = var.db_name

  tags = var.tags
}
