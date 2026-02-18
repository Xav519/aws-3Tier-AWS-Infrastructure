
# Create RDS Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Main RDS Instance
resource "aws_db_instance" "main" {
  identifier              = "${var.project_name}-db-main"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.username
  password                = var.password

  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids

  multi_az                = var.multi_az // Enable Multi-AZ for high availability if needed
  backup_retention_period = var.backup_retention_period

  skip_final_snapshot     = true // For development, set to false in production to avoid data loss
  publicly_accessible     = false

  tags = {
    Name = "${var.project_name}-db-main"
  }
}

# Read Replica
resource "aws_db_instance" "replica" {
  identifier             = "${var.project_name}-db-replica"
  replicate_source_db    = aws_db_instance.main.identifier
  instance_class         = var.instance_class
  publicly_accessible    = false

  vpc_security_group_ids = var.vpc_security_group_ids

  depends_on = [aws_db_instance.main]

  tags = {
    Name = "${var.project_name}-db-replica"
  }
}

