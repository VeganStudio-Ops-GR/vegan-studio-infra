resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "VeganStudio-Production-Overview"

  dashboard_body = jsonencode({
    widgets = [
      # 1. Total Traffic (Metric)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Total Traffic (ALB)"
        }
      },

      # 2. Server Errors (Metric)
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Server Errors (5XX)"
        }
      },

      # 3. ASG CPU Usage (Metric)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${var.project_name}-asg"]
          ]
          period = 300
          stat   = "Average"
          region = "ap-south-1"
          title  = "ASG Cluster CPU Usage"
        }
      },

      # ---------------------------------------------------------
      # NEW: LOG WIDGETS (The "Why" Factor)
      # ---------------------------------------------------------

      # 4. Application Error Logs (Canary Monitor)
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE 'vegan-studio-apache-errors' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          region = "ap-south-1"
          title  = "Live Application Errors (Canary/Blue-Green Monitor)"
        }
      },

      # 5. Infrastructure Provisioning Logs (Bootstrap Check)
      {
        type   = "log"
        x      = 0
        y      = 18
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE 'vegan-studio-provisioning-logs' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          region = "ap-south-1"
          title  = "Provisioning Progress (User-Data Logs)"
        }
      }
    ]
  })
}
