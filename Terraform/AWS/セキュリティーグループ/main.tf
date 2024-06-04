locals {
  all_ips = ["0.0.0.0/0"]
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
}

resource "aws_security_group" "app" {
  name = "app"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  security_group_id = aws_security_group.instance.id
  type = "ingress"

  from_port = 8080
  to_port = 8080
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