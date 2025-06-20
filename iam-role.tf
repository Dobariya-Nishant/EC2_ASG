resource "aws_iam_role" "ecs_instance_role" {
  count = var.ecs_cluster_name != null ? 1 : 0

  name               = "${local.pre_fix}-ecsInstanceRole" 
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attach" {
  count = var.ecs_cluster_name != null ? 1 : 0

  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = data.aws_iam_policy.ecs_ec2_role_policy.arn
}

resource "aws_iam_instance_profile" "ecs_profile" {
  count = var.ecs_cluster_name != null ? 1 : 0

  name = "${local.pre_fix}-ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role[0].name
}
