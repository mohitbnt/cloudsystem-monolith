# Create a target group for the ALB
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-${var.environment}-alb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  deregistration_delay = 30

  health_check {
    enabled = true
    path    = "/"
    port    = 80
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-target-group"
    }
  )
}

# Create ALB
resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false
  enable_http2 = true
  idle_timeout = 60

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

# Create ALB listener for HTTP
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create ALB listener for HTTPS
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.tls_certificate_arn
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}