resource "aws_placement_group" "strategy" {
  name     = local.placement_group_name
  strategy = var.instance_placement_strategy
}

resource "aws_autoscaling_group" "multi_az_group" {
  name                      = local.auto_scaling_group_name
  desired_capacity          = 1
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = var.health_check_type
  placement_group           = aws_placement_group.strategy.id
  vpc_zone_identifier       = local.subnet_ids

  target_group_arns = var.target_group_arns

  metrics_granularity = "1Minute"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances",
  ]

  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = aws_launch_template.ec2_template.latest_version
  }
}

resource "aws_autoscaling_policy" "scale_out_cpu" {
  count = var.enable_auto_scaling_alarms == true ? 1 : 0

  name                   = "scale-out-cpu"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.multi_az_group.name
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_in_cpu" {
  count = var.enable_auto_scaling_alarms == true ? 1 : 0

  name                   = "scale-in-cpu"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.multi_az_group.name
  policy_type            = "SimpleScaling"
}
