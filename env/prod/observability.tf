resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "VeganStudio-Production-Overview"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: ALB Request Count
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.alb.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Total Traffic (ALB)"
        }
      },
      # Widget 2: 5XX Errors (The "Panic" Metric)
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", module.alb.alb_arn_suffix]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Server Errors (5XX)"
          color  = "#d62728"
        }
      },
      # Widget 3: CPU Utilization (Saturation)
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.asg.asg_name]
          ]
          period = 300
          stat   = "Average"
          region = "ap-south-1"
          title  = "ASG Cluster CPU Usage"
        }
      }
    ]
  })
}
