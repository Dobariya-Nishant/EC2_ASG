resource "aws_security_group" "sg" {
  name        = "${local.pre_fix}-${local.visibility}-sg"
  description = "Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.pre_fix}-${local.visibility}-sg"
    }
  )
}

resource "aws_security_group_rule" "current_ip_ssh" {
  count = var.enable_ssh_from_current_ip ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_ip_cidr]
  description       = "Allow SSH"
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "public_ssh" {
  count = var.enable_public_ssh ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH"
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "public_http" {
  count = var.enable_public_http == true ? 1 : 0

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP"
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "public_https" {
  count = var.enable_public_https == true ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS"
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "loadbalancer_sg_access" {
  count = length(var.load_balancer_config)

  type                     = "ingress"
  from_port                = var.load_balancer_config[count.index].port
  to_port                  = var.load_balancer_config[count.index].port
  protocol                 = var.load_balancer_config[count.index].protocol
  source_security_group_id = var.load_balancer_config[count.index].sg_id
  description              = "Allow HTTPS"
  security_group_id        = aws_security_group.sg.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}