# --- Backend IAM Role ---
resource "aws_iam_role" "backend_role" {
  name = "${var.project_name}-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# --- Secrets Manager Policy ---
# Allows the Backend to pull the DB password
resource "aws_iam_role_policy" "backend_secrets_policy" {
  name = "${var.project_name}-backend-secrets-policy"
  role = aws_iam_role.backend_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = var.db_secret_arn
      }
    ]
  })
}

# --- Instance Profile ---
# This is the "container" that you attach to the Launch Template
resource "aws_iam_instance_profile" "backend_instance_profile" {
  name = "${var.project_name}-backend-instance-profile"
  role = aws_iam_role.backend_role.name
}