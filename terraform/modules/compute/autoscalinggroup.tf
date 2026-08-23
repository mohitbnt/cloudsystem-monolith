# Create Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name = "${var.project_name}-${var.environment}-asg"
  min_size = var.app_instance_config.min_size
  max_size = var.app_instance_config.max_size
  desired_capacity = var.app_instance_config.desired_capacity
  health_check_grace_period = var.app_instance_config.health_check_grace_period
  health_check_type = var.app_instance_config.health_check_type
  protect_from_scale_in = var.app_instance_config.protect_scale_in
  vpc_zone_identifier = var.private_subnet_ids
  launch_template {
    id = aws_launch_template.ec2_launch_template.id
    version = aws_launch_template.ec2_launch_template.latest_version
  }
  target_group_arns = [aws_lb_target_group.alb_target_group.arn]
  termination_policies = var.app_instance_config.termination_policy
  force_delete = false

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
    ]
    tag {
      key = "Name"
      value = "${var.project_name}-${var.environment}-asg"
      propagate_at_launch = true
    }
    tag {
      key = "Project"
      value = var.project_name
      propagate_at_launch = true
    }
    tag {
      key = "Environment"
      value = var.environment
      propagate_at_launch = true
    }   
}