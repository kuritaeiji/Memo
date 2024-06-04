locals {
  all_ips = ["0.0.0.0/0"]
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
}

resource "aws_launch_configuration" "app" {
  image_id = var.ami
  instance_type = var.instance_type

  security_groups = [aws_security_group.instance.id]
  # パブリックIPアドレスの付与設定
  associate_public_ip_address = var.associate_public_ip_address

  user_data = var.user_data

  # ASGに紐づく起動設定が無くならないように新しい起動設定を作成してから既存の起動設定を削除する
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  name = var.cluster_name
  launch_configuration = aws_launch_configuration.app.name

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = var.target_group_arns
  health_check_type = var.health_chek_type

  min_size = var.min_size
  max_size = var.max_size

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key = "Name"
    value = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  security_group_id = aws_security_group.instance.id
  type = "ingress"

  from_port = var.server_port
  to_port = var.server_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.instance.id
  type = "egress"

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}
