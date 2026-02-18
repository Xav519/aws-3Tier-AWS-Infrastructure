
# Create the ALB
resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.alb_name}"
  # Set internal to true if alb_type is "internal", otherwise false
  internal           = var.alb_type == "internal" ? true : false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnet_ids

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name = "${var.project_name}-${var.alb_name}"
  }
}

# Create Target Group
resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-${var.target_group_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check { # Configure health check settings to be able to monitor the health of the targets
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-${var.target_group_name}"
  }
}

# Create Listeners for each port
resource "aws_lb_listener" "this" {
  for_each = toset([for p in var.listener_ports : tostring(p)]) # Create a listener for each port specified in the variable

  load_balancer_arn = aws_lb.this.arn
  port              = each.value
  protocol          = each.value == 443 ? "HTTPS" : "HTTP" # Use HTTPS protocol for port 443, otherwise HTTP

  default_action {
    type             = "forward" # Forward traffic to the target group when it matches the listener rules
    target_group_arn = aws_lb_target_group.this.arn
  }
}
