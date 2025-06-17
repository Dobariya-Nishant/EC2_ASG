data "template_file" "ecs_user_data" {
  count = var.ecs_cluster_name != null ? 1 : 0
  template = file("${path.module}/scripts/ecs_cluster_registration.sh.tpl")

  vars = {
    ecs_cluster_name = var.ecs_cluster_name
  }
}

data "template_file" "init_user_data" {
  template = file("${path.module}/scripts/init.sh.tpl")
}
