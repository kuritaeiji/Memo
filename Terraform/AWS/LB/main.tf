resource "aws_lb" "app" {
  name = var.name
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = [aws_security_group.lb.id]
}

resource "aws_security_group" "lb" {
  name = "${var.name}-lb"
}

resource "aws_security_group_rule" "ingress_rules" {
  security_group_id = aws_security_group.lb.id
  type = "ingress"

  for_each = toset(var.lister_ports)

  from_port = each.value
  to_port = each.value
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_rule" {
  security_group_id = aws_security_group.lb.id
  type = "egress"

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb_listener" "app" {
  for_each = toset(var.lister_ports)

  load_balancer_arn = aws_lb.app.arn
  port = each.value
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_listener_rule" "app" {
  listener_arn = aws_lb_listener.app.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name = var.name
  port = var.server_port 
  protocol = "HTTP"
  vpc_id = var.server_vpc_id

  health_check {
    path = "/healthcheck"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}