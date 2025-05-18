resource "aws_cloudwatch_metric_alarm" "scale_out_cpu" {
  count = var.enable_auto_scaling_alarms == true ? 1 : 0

  alarm_name          = local.scale_out_metric_alarm_name
  alarm_description   = "Scale out when CPU > 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.multi_az_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_out_cpu[0].arn]

  tags = merge(
    local.common_tags,
    {
      Name = local.scale_out_metric_alarm_name
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "scale_in_cpu" {
  count = var.enable_auto_scaling_alarms == true ? 1 : 0

  alarm_name          = local.scale_in_metric_alarm_name
  alarm_description   = "Scale in when CPU < 60%"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.multi_az_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_in_cpu[0].arn]

  tags = merge(
    local.common_tags,
    {
      Name = local.scale_in_metric_alarm_name
    }
  )
}

