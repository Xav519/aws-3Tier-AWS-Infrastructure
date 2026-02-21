resource "aws_launch_template" "frontend" {
  name_prefix   = "${var.project_name}-frontend-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

user_data = base64encode(templatefile("${path.root}/scripts/frontend_user_data.sh", {
    docker_image         = var.docker_image
    dockerhub_username   = var.dockerhub_username
    dockerhub_password   = var.dockerhub_password
    backend_internal_url = var.backend_internal_url
    project              = var.project_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-frontend"
      Layer = "presentation"
    }
  }
}

# Create the Auto Scaling Group for the frontend layer
resource "aws_autoscaling_group" "frontend" {
  name                      = "${var.project_name}-frontend-asg"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-frontend"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

