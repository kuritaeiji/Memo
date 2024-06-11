terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_security_group" "default" {
  name = var.name
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }
}

resource "aws_security_group_rule" "ingress" {
  type = "ingress"
  security_group_id = aws_security_group.default.id

  from_port = var.ingress_port
  to_port = var.ingress_port
  protocol = var.ingress_protocol
  cidr_blocks = var.ingress_cidr_blocks
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  security_group_id = aws_security_group.default.id

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}