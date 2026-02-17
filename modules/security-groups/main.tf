# Bastion Host SG
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Bastion host SG"
  vpc_id      = var.vpc_id

  # Inbound SSH from Internet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Changer ici par valeur plus restrictive pour limiter l'accès SSH à une plage d'adresses IP spécifique
  }

  # Outbound SSH to private EC2s
  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    // Utiliser security_groups pour autoriser uniquement le trafic SSH vers les EC2 des tiers Presentation et Logic
    security_groups = [aws_security_group.presentation_ec2.id, aws_security_group.logic_ec2.id]
  }

  tags = { Name = "${var.project_name}-bastion-sg" }
}


# External ALB SG
resource "aws_security_group" "external_alb" {
  name        = "${var.project_name}-external-alb-sg"
  description = "External ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autoriser HTTP depuis Internet
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    // Autoriser HTTPS depuis Internet
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    // Autoriser tout le trafic sortant (ou restreindre vers les EC2 des tiers Presentation et Logic)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = { Name = "${var.project_name}-external-alb-sg" }
}


# Tier 1 EC2 SG (Presentation)
resource "aws_security_group" "presentation_ec2" {
  name        = "${var.project_name}-presentation-sg"
  description = "Tier 1 EC2 SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autoriser HTTP depuis l'External ALB uniquement
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  ingress {
    // Autoriser HTTPS depuis l'External ALB uniquement
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  ingress {
    // Autoriser SSH depuis le Bastion Host uniquement
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    // Autoriser tout le trafic sortant (ou restreindre vers l'Internal ALB SG)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # ou vers internal ALB SG
  }

  tags = { Name = "${var.project_name}-presentation-sg" }
}

# Internal ALB SG (Tier1 → Tier2)
resource "aws_security_group" "internal_alb" {
  name        = "${var.project_name}-internal-alb-sg"
  description = "Internal ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autoriser HTTP depuis les EC2 du tier Presentation uniquement
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.presentation_ec2.id]
  }

  egress {
    // Autoriser tout le trafic sortant (ou restreindre vers les EC2 du tier Logic)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-internal-alb-sg" }
}

# Tier 2 EC2 SG (Logic)
resource "aws_security_group" "logic_ec2" {
  name        = "${var.project_name}-logic-sg"
  description = "Tier 2 EC2 SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autoriser HTTP depuis l'Internal ALB uniquement
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  ingress {
    // Autoriser SSH depuis le Bastion Host uniquement
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    // Autoriser tout le trafic sortant  vers les RDS SGs
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_main.id]
  }

  tags = { Name = "${var.project_name}-logic-sg" }
}

# Main RDS SG
resource "aws_security_group" "rds_main" {
  name        = "${var.project_name}-rds-main-sg"
  description = "RDS main SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autoriser MySQL depuis les EC2 du tier Logic uniquement
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.logic_ec2.id]
  }

  tags = { Name = "${var.project_name}-rds-main-sg" }
}


# Replica RDS SG
# TODO : review logic and see if we need a sg for replica db
resource "aws_security_group" "rds_replica" {
  name        = "${var.project_name}-rds-replica-sg"
  description = "RDS replica SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autoriser la réplication MySQL depuis le RDS principal uniquement
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_main.id]
  }

  tags = { Name = "${var.project_name}-rds-replica-sg" }
}
