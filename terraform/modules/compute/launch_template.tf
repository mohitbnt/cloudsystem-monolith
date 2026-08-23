# Create instance profile for the EC2 instances
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-${var.environment}-ec2-instance-profile"
  role = var.ec2_role_name
}

# Create a launch template for the EC2 instances
resource "aws_launch_template" "ec2_launch_template" {
  name = "${var.project_name}-${var.environment}-ec2-launch-template"
  image_id = var.golden_ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [var.ec2_security_group_id]
  update_default_version = true
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_instance_profile.arn
  }
  monitoring {
    enabled = true
  }
  block_device_mappings {
    device_name = data.aws_ami.selected_ami.root_device_name
    ebs {
      volume_size = var.app_instance_config.root_volume_size
      volume_type = var.app_instance_config.root_volume_type
      encrypted = var.app_instance_config.root_volume_encrypted
      iops = 3000
      throughput = 125
      delete_on_termination = true
    }
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags = "enabled"
  }
  lifecycle {
    create_before_destroy = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-web-instance"
      }
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-web-volume"
      }
    )
  }
}