data "aws_ami" "amazon_linux_2023_ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ecs-ami-*-x86_64"] # ECS optimized pattern
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon official
}

data "aws_iam_policy" "ecs_ec2_role_policy" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}