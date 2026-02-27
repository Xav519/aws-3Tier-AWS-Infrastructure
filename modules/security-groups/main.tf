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
    cidr_blocks = ["0.0.0.0/0"] // should be restricted to specific IPs
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


  tags = { Name = "${var.project_name}-bastion-sg" }
}


# External ALB SG
resource "aws_security_group" "external_alb" {
  name        = "${var.project_name}-external-alb-sg"
  description = "External ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autorize HTTP from Internet
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    // Autorize HTTP from Internet
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
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
    // Autorize HTTP from the External ALB only
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  ingress {
    // Autorize HTTPS from the External ALB only
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  ingress {
    // Autorize SSH from the Bastion Host only
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    // Autorize all outbound traffic (or restrict to Internal ALB SG)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-presentation-sg" }
}

# Internal ALB SG (Tier1 → Tier2)
resource "aws_security_group" "internal_alb" {
  name        = "${var.project_name}-internal-alb-sg"
  description = "Internal ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autorize HTTP from the Presentation EC2s only
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.presentation_ec2.id]
  }

  ingress {
    // Autorize HTTPS from the Presentation EC2s only
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.presentation_ec2.id]
  }

  egress {
    // Autorize all outbound traffic (or restrict to Logic EC2 SG)
    from_port   = 0
    to_port     = 0
    protocol    = -1
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
    // Autorize HTTP from the Internal ALB only
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  ingress {
    // Autorize HTTPS from the Internal ALB only
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  ingress {
    description     = "Traffic from Internal ALB"
    from_port       = 8080  # The port your Docker container uses
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id] # Only allow the ALB!
  }
  
  ingress {
    // Autorize SSH from the Bastion Host only
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    // Autorize all outbound traffic (or restrict to RDS SG)
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-logic-sg" }
}

# Main RDS SG
resource "aws_security_group" "rds_main" {
  name        = "${var.project_name}-rds-main-sg"
  description = "RDS main SG"
  vpc_id      = var.vpc_id

  ingress {
    // Autorize Postgres from the Logic EC2s only
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.logic_ec2.id]
  }


  tags = { Name = "${var.project_name}-rds-main-sg" }
}
