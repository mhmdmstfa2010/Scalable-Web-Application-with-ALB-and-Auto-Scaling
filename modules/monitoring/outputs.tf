output "sns_topic_arn" {
  value       = aws_sns_topic.monitoring_alarms.arn
  description = "ARN of the SNS topic for alarms"
}

output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.main.dashboard_name
  description = "Name of the CloudWatch dashboard"
}

output "alarm_names" {
  value = {
    cpu          = aws_cloudwatch_metric_alarm.cpu_alarm.alarm_name
    response_time = aws_cloudwatch_metric_alarm.response_time_alarm.alarm_name
    rds_cpu      = aws_cloudwatch_metric_alarm.rds_cpu_alarm.alarm_name
    error_rate   = aws_cloudwatch_metric_alarm.error_rate_alarm.alarm_name
  }
  description = "Names of all CloudWatch alarms"
} 