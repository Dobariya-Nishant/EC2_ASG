resource "aws_launch_template" "ec2_template" {
  name          = local.launch_template_name
  instance_type = var.instance_type
  image_id      = local.image_id
  key_name      = local.key_pair_name

  user_data = base64encode(local.user_data)

  dynamic "instance_market_options" {
    for_each = var.use_spot ? [1] : []
    content {
      market_type = "spot"
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.ecs_cluster_name != null && length(aws_iam_instance_profile.ecs_profile) > 0 ? [1] : []
    content {
      name = aws_iam_instance_profile.ecs_profile[0].name
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_size
      volume_type           = var.ebs_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  network_interfaces {
    associate_public_ip_address = local.visibility == "public" ? true : false
    security_groups             = [aws_security_group.sg.id]
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.launch_template_name
    }
  )
}