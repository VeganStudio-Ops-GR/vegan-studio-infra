output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.app_lb.arn_suffix
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
