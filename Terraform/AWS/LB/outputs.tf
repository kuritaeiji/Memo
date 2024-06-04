output "lb_dns_name" {
  value = aws_lb.app.dns_name
}

output "lb_security_group_id" {
  value = aws_security_group.lb.id
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.app.arn
}